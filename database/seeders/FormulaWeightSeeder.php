<?php

namespace Database\Seeders;

use App\Models\FormulaWeight;
use Illuminate\Database\Seeder;

class FormulaWeightSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        if (FormulaWeight::query()->exists()) {
            return;
        }

        foreach (FormulaWeight::COMPONENTS as $aggregate => $components) {
            $equalWeight = round(1 / count($components), 4);

            foreach ($components as $component) {
                FormulaWeight::create([
                    'aggregate' => $aggregate,
                    'component' => $component,
                    'weight' => $equalWeight,
                ]);
            }
        }
    }
}
