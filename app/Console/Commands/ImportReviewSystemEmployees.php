<?php

namespace App\Console\Commands;

use App\Models\Department;
use App\Models\Employee;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;

class ImportReviewSystemEmployees extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:import-review-system-employees';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import departments and employees from the review-system database';

    public function handle(): int
    {
        Config::set('database.connections.review_system', array_merge(
            config('database.connections.mysql'),
            ['database' => 'review-system']
        ));

        $source = DB::connection('review_system');

        $departments = $source->table('departments')->get(['id', 'name']);
        $departmentIdMap = [];

        foreach ($departments as $department) {
            $local = Department::firstOrCreate(['name' => $department->name]);
            $departmentIdMap[$department->id] = $local->id;
        }

        $this->info("Imported {$departments->count()} departments.");

        $users = $source->table('users')
            ->whereNotNull('department_id')
            ->get(['name', 'email', 'job_title', 'department_id']);

        $created = 0;

        foreach ($users as $user) {
            Employee::firstOrCreate(
                ['email' => $user->email],
                [
                    'name' => $user->name,
                    'position' => $user->job_title,
                    'department_id' => $departmentIdMap[$user->department_id] ?? null,
                ]
            );
            $created++;
        }

        $this->info("Imported {$created} employees.");

        return self::SUCCESS;
    }
}
