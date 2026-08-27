<?php

namespace Tests\Feature;

use App\Models\Account;
use App\Models\Cycle;
use App\Models\Performance;
use App\Services\PerformanceCycleAssigner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PerformanceCycleAssignerTest extends TestCase
{
    use RefreshDatabase;

    private function assigner(): PerformanceCycleAssigner
    {
        return app(PerformanceCycleAssigner::class);
    }

    /**
     * Creates a Performance and runs it through the assigner exactly like
     * PerformanceController::store() does, since the factory alone doesn't
     * (assignment is a controller-level concern, not a model event).
     */
    private function createAssignedPerformance(Account $account, array $attributes): Performance
    {
        $performance = Performance::factory()->for($account)->make($attributes);
        $this->assigner()->assign($performance);
        $performance->save();

        return $performance;
    }

    public function test_assigns_a_post_dated_inside_a_cycles_range(): void
    {
        $account = Account::factory()->create();
        $cycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-29',
        ]);

        $this->assertSame($cycle->id, $performance->fresh()->cycle_id);
    }

    public function test_boundaries_are_inclusive_on_both_ends(): void
    {
        $account = Account::factory()->create();
        $cycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $onStart = $this->createAssignedPerformance($account, ['platform' => 'instagram', 'post_date' => '2026-07-01']);
        $onEnd = $this->createAssignedPerformance($account, ['platform' => 'instagram', 'post_date' => '2026-07-31']);

        $this->assertSame($cycle->id, $onStart->fresh()->cycle_id);
        $this->assertSame($cycle->id, $onEnd->fresh()->cycle_id);
    }

    public function test_post_outside_any_cycle_range_stays_unassigned(): void
    {
        $account = Account::factory()->create();
        Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-08-05',
        ]);

        $this->assertNull($performance->fresh()->cycle_id);
    }

    public function test_platform_must_match_between_cycle_and_post(): void
    {
        $account = Account::factory()->create();
        Cycle::factory()->for($account)->create([
            'platform' => 'tiktok',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-15',
        ]);

        $this->assertNull($performance->fresh()->cycle_id);
    }

    public function test_editing_a_cycles_date_range_reassigns_posts_that_fall_out_of_range(): void
    {
        $account = Account::factory()->create();
        $cycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-29',
        ]);

        $this->assertSame($cycle->id, $performance->fresh()->cycle_id);

        $cycleAssigner = $this->assigner();

        // Mirrors CycleController::update(): apply the edit first, then sync anything
        // newly in range, then re-resolve posts still pointing at this cycle that may
        // have fallen outside its new (now-shrunk) range.
        $cycle->update(['cycle_end_date' => '2026-07-20']);
        $cycleAssigner->syncForCycle($cycle);
        $cycleAssigner->reassignAwayFromCycle($cycle);

        $this->assertNull($performance->fresh()->cycle_id);
    }

    public function test_editing_a_cycle_backfills_a_previously_unassigned_post(): void
    {
        $account = Account::factory()->create();
        $cycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-15',
        ]);

        // Posted after the cycle's original end date — starts out unassigned.
        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-20',
        ]);

        $this->assertNull($performance->fresh()->cycle_id);

        $cycleAssigner = $this->assigner();
        $cycle->update(['cycle_end_date' => '2026-07-31']);
        $cycleAssigner->syncForCycle($cycle);
        $cycleAssigner->reassignAwayFromCycle($cycle);

        $this->assertSame($cycle->id, $performance->fresh()->cycle_id);
    }

    public function test_deleting_a_cycle_falls_back_to_another_covering_cycle_instead_of_going_null(): void
    {
        $account = Account::factory()->create();

        $narrowCycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-15',
        ]);

        $wideCycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-06-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-10',
        ]);

        // Whichever cycle the query happens to match first "owns" the post; force it onto the narrow one.
        $performance->update(['cycle_id' => $narrowCycle->id]);

        // Mirrors CycleController::destroy(): capture affected posts, delete the cycle
        // (nullOnDelete clears their cycle_id), then re-resolve the captured posts.
        $cycleAssigner = $this->assigner();
        $affectedIds = $narrowCycle->performances()->pluck('id');
        $narrowCycle->delete();
        $cycleAssigner->reassignMany(Performance::whereIn('id', $affectedIds)->get());

        $this->assertSame($wideCycle->id, $performance->fresh()->cycle_id);
    }

    public function test_deleting_the_only_covering_cycle_leaves_the_post_unassigned(): void
    {
        $account = Account::factory()->create();
        $cycle = Cycle::factory()->for($account)->create([
            'platform' => 'instagram',
            'cycle_start_date' => '2026-07-01',
            'cycle_end_date' => '2026-07-31',
        ]);

        $performance = $this->createAssignedPerformance($account, [
            'platform' => 'instagram',
            'post_date' => '2026-07-10',
        ]);

        $this->assertSame($cycle->id, $performance->fresh()->cycle_id);

        $cycleAssigner = $this->assigner();
        $affectedIds = $cycle->performances()->pluck('id');
        $cycle->delete();
        $cycleAssigner->reassignMany(Performance::whereIn('id', $affectedIds)->get());

        $this->assertNull($performance->fresh()->cycle_id);
    }
}
