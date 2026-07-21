<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\CycleController;
use App\Http\Controllers\FormulaWeightController;
use App\Http\Controllers\LabelBucketController;
use App\Http\Controllers\ScoreBucketController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth')->group(function () {
    Route::redirect('/', '/cycles');

    Route::resource('accounts', AccountController::class)
        ->only(['index', 'store', 'update', 'destroy']);
    Route::get('accounts/{account}/growth', [AccountController::class, 'growth'])->name('accounts.growth');
    Route::post('accounts/{account}/pdf', [AccountController::class, 'pdf'])->name('accounts.pdf');
    Route::post('accounts/{account}/summarize', [AccountController::class, 'summarize'])->name('accounts.summarize');

    Route::resource('cycles', CycleController::class)
        ->only(['index', 'store', 'update', 'destroy']);

    Route::get('accounts/{account}/neighboring-cycle', [CycleController::class, 'neighboring'])->name('cycles.neighboring');
    Route::get('cycles-pdf', [CycleController::class, 'pdf'])->name('cycles.pdf');
    Route::get('cycles/{cycle}/pdf', [CycleController::class, 'pdfSingle'])->name('cycles.pdf-single');
    Route::post('cycles/{cycle}/summarize', [CycleController::class, 'summarize'])->name('cycles.summarize');
    Route::post('cycles-summarize', [CycleController::class, 'summarizeFiltered'])->name('cycles.summarize-filtered');

    Route::resource('score-buckets', ScoreBucketController::class)
        ->only(['index', 'store', 'update', 'destroy']);

    Route::resource('label-buckets', LabelBucketController::class)
        ->only(['store', 'update', 'destroy']);

    Route::put('formula-weights/{aggregate}', [FormulaWeightController::class, 'update'])
        ->name('formula-weights.update');
});
