<?php

namespace App\Console\Commands;

use App\Models\Account;
use App\Models\InstagramDailySnapshot;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;

class BackfillInstagramDailySnapshots extends Command
{
    protected $signature = 'instagram:backfill-daily-snapshots {account_id? : Backfill only this account; omit to backfill all connected accounts} {--days=7 : How many past days to backfill (Instagram only exposes reach time_series for a limited window)}';

    protected $description = 'Backfill past days of Instagram "reach" history (the only day-metric Instagram exposes retroactively via time_series)';

    private const BASE_URL = 'https://graph.instagram.com';

    public function handle(): int
    {
        $days = (int) $this->option('days');

        $accounts = $this->argument('account_id')
            ? Account::where('id', $this->argument('account_id'))->get()
            : Account::whereNotNull('ig_business_id')->whereNotNull('ig_access_token')->get();

        if ($accounts->isEmpty()) {
            $this->error('No connected accounts found.');

            return self::FAILURE;
        }

        foreach ($accounts as $account) {
            $this->backfillAccount($account, $days);
        }

        return self::SUCCESS;
    }

    private function backfillAccount(Account $account, int $days): void
    {
        try {
            $response = Http::get(self::BASE_URL."/{$account->ig_business_id}/insights", [
                'metric' => 'reach',
                'period' => 'day',
                'metric_type' => 'time_series',
                'since' => now()->subDays($days)->timestamp,
                'until' => now()->timestamp,
                'access_token' => $account->ig_access_token,
            ])->throw();
        } catch (\Throwable $e) {
            $this->error("✗ {$account->name}: {$e->getMessage()}");

            return;
        }

        $values = $response->json('data.0.values', []);
        $today = today()->toDateString();
        $saved = 0;

        foreach ($values as $point) {
            $date = Carbon::parse($point['end_time'])->toDateString();

            if ($date === $today) {
                continue;
            }

            InstagramDailySnapshot::updateOrCreate(
                ['account_id' => $account->id, 'captured_date' => $date],
                ['reach' => $point['value'], 'captured_at' => now()]
            );

            $saved++;
        }

        $this->line("✓ {$account->name}: backfilled reach for {$saved} day(s)");
    }
}
