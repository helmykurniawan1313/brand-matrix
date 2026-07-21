<?php

namespace Database\Factories;

use App\Models\Account;
use App\Models\Cycle;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Cycle>
 */
class CycleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $start = fake()->dateTimeBetween('-11 months', '-1 month');
        $end = (clone $start)->modify('+' . fake()->numberBetween(21, 35) . ' days');

        $startFollower = fake()->numberBetween(500, 150000);

        // Occasionally simulate a decline; otherwise growth up to ~20%.
        $growthRate = fake()->boolean(15)
            ? fake()->randomFloat(4, -0.08, 0)
            : fake()->randomFloat(4, 0, 0.20);
        $endFollower = max(0, (int) round($startFollower * (1 + $growthRate)));

        $reach = fake()->numberBetween(0, (int) ($endFollower * 3));
        $views = fake()->numberBetween(0, (int) ($endFollower * 5));
        $engagement = fake()->numberBetween(0, (int) ($reach * 0.15));

        return [
            'account_id' => Account::factory(),
            'cycle_start_date' => $start,
            'cycle_end_date' => $end,
            'start_follower' => $startFollower,
            'end_follower' => $endFollower,
            'reach' => $reach,
            'views' => $views,
            'engagement' => $engagement,
        ];
    }
}
