<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\CycleController;
use App\Http\Controllers\DepartmentController;
use App\Http\Controllers\EmployeeController;
use App\Http\Controllers\FormulaWeightController;
use App\Http\Controllers\InstagramController;
use App\Http\Controllers\LabelBucketController;
use App\Http\Controllers\PerformanceController;
use App\Http\Controllers\ScoreBucketController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth')->group(function () {
    Route::redirect('/', '/cycles');

    Route::resource('accounts', AccountController::class)
        ->only(['index', 'store', 'update', 'destroy']);
    Route::get('accounts/{account}/growth', [AccountController::class, 'growth'])->name('accounts.growth');
    Route::post('accounts/{account}/pdf', [AccountController::class, 'pdf'])->name('accounts.pdf');
    Route::post('accounts/{account}/summarize', [AccountController::class, 'summarize'])->name('accounts.summarize');

    Route::post('accounts/{account}/instagram/connect', [InstagramController::class, 'connect'])->name('accounts.instagram.connect');
    Route::delete('accounts/{account}/instagram/disconnect', [InstagramController::class, 'disconnect'])->name('accounts.instagram.disconnect');
    Route::get('accounts/{account}/instagram', [InstagramController::class, 'show'])->name('accounts.instagram.show');
    Route::get('accounts/{account}/instagram/oauth/redirect', [InstagramController::class, 'redirect'])->name('accounts.instagram.oauth.redirect');
    Route::get('accounts/{account}/instagram/media-insights', [InstagramController::class, 'mediaInsights'])->name('accounts.instagram.media-insights');

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

    Route::resource('departments', DepartmentController::class)
        ->only(['index', 'store', 'update', 'destroy']);

    Route::resource('employees', EmployeeController::class)
        ->only(['index', 'store', 'update', 'destroy']);

    Route::resource('performances', PerformanceController::class)
        ->only(['index', 'store', 'update', 'destroy']);
});

Route::get('instagram/oauth/callback', [InstagramController::class, 'callback'])->name('instagram.oauth.callback');
