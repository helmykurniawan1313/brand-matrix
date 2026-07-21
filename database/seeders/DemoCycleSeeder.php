<?php

namespace Database\Seeders;

use App\Models\Account;
use App\Models\Cycle;
use Illuminate\Database\Seeder;

class DemoCycleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $accounts = Account::factory()->count(8)->create();

        Cycle::factory()
            ->count(50)
            ->state(fn () => ['account_id' => $accounts->random()->id])
            ->create();
    }
}
