<?php

use App\Http\Controllers\AccountController;
use App\Http\Controllers\CycleController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\DepartmentController;
use App\Http\Controllers\EmployeeController;
use App\Http\Controllers\FormulaWeightController;
use App\Http\Controllers\InstagramController;
use App\Http\Controllers\LabelBucketController;
use App\Http\Controllers\LegalPageController;
use App\Http\Controllers\PerformanceController;
use App\Http\Controllers\ScoreBucketController;
use App\Http\Controllers\SiteSettingController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ViewsTrendController;
use App\Models\LegalPage;
use Illuminate\Support\Facades\Route;

Route::middleware('auth')->group(function () {
    Route::redirect('/', '/dashboard');

    // --- Read-only routes: any authenticated user (including viewers) ---

    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::get('views-trend', [ViewsTrendController::class, 'index'])->name('views-trend.index');
    Route::get('views-trend-pdf', [ViewsTrendController::class, 'pdf'])->name('views-trend.pdf');
    Route::get('views-trend-excel', [ViewsTrendController::class, 'exportExcel'])->name('views-trend.excel');
    Route::get('views-trend/{account}', [ViewsTrendController::class, 'detail'])->name('views-trend.detail');

    Route::resource('accounts', AccountController::class)->only(['index']);
    Route::get('accounts/{account}/growth', [AccountController::class, 'growth'])->name('accounts.growth');
    Route::post('accounts/{account}/pdf', [AccountController::class, 'pdf'])->name('accounts.pdf');
    Route::post('accounts/{account}/summarize', [AccountController::class, 'summarize'])->name('accounts.summarize');
    Route::get('accounts/{account}/instagram', [InstagramController::class, 'show'])->name('accounts.instagram.show');
    Route::get('accounts/{account}/instagram/media-insights', [InstagramController::class, 'mediaInsights'])->name('accounts.instagram.media-insights');
    Route::get('accounts/{account}/instagram/media', [InstagramController::class, 'mediaList'])->name('accounts.instagram.media');

    Route::resource('cycles', CycleController::class)->only(['index']);
    Route::get('accounts/{account}/neighboring-cycle', [CycleController::class, 'neighboring'])->name('cycles.neighboring');
    Route::get('cycles-pdf', [CycleController::class, 'pdf'])->name('cycles.pdf');
    Route::get('cycles-excel', [CycleController::class, 'exportExcel'])->name('cycles.excel');
    Route::get('cycles/{cycle}/pdf', [CycleController::class, 'pdfSingle'])->name('cycles.pdf-single');
    Route::post('cycles/{cycle}/summarize', [CycleController::class, 'summarize'])->name('cycles.summarize');
    Route::post('cycles-summarize', [CycleController::class, 'summarizeFiltered'])->name('cycles.summarize-filtered');

    Route::resource('score-buckets', ScoreBucketController::class)->only(['index']);

    Route::resource('departments', DepartmentController::class)->only(['index']);

    Route::resource('employees', EmployeeController::class)->only(['index']);

    Route::resource('performances', PerformanceController::class)->only(['index']);
    Route::get('performances/{performance}/pdf', [PerformanceController::class, 'pdf'])->name('performances.pdf');
    Route::post('performances/{performance}/summarize', [PerformanceController::class, 'summarize'])->name('performances.summarize');
    Route::get('performances-pdf', [PerformanceController::class, 'pdfFiltered'])->name('performances.pdf-filtered');
    Route::get('performances-excel', [PerformanceController::class, 'exportExcel'])->name('performances.excel');
    Route::post('performances-summarize', [PerformanceController::class, 'summarizeFiltered'])->name('performances.summarize-filtered');

    Route::get('settings/legal-pages', [LegalPageController::class, 'edit'])->name('legal-pages.edit');

    // --- Write routes: editors and super_admins only ---

    Route::middleware('can-edit')->group(function () {
        Route::resource('accounts', AccountController::class)->only(['store', 'update', 'destroy']);
        Route::post('accounts/{account}/instagram/connect', [InstagramController::class, 'connect'])->name('accounts.instagram.connect');
        Route::delete('accounts/{account}/instagram/disconnect', [InstagramController::class, 'disconnect'])->name('accounts.instagram.disconnect');
        Route::get('accounts/{account}/instagram/oauth/redirect', [InstagramController::class, 'redirect'])->name('accounts.instagram.oauth.redirect');

        Route::resource('cycles', CycleController::class)->only(['store', 'update', 'destroy']);

        Route::resource('score-buckets', ScoreBucketController::class)->only(['store', 'update', 'destroy']);

        Route::resource('label-buckets', LabelBucketController::class)->only(['store', 'update', 'destroy']);

        Route::put('formula-weights/{aggregate}', [FormulaWeightController::class, 'update'])
            ->name('formula-weights.update');

        Route::resource('departments', DepartmentController::class)->only(['store', 'update', 'destroy']);

        Route::resource('employees', EmployeeController::class)->only(['store', 'update', 'destroy']);

        Route::resource('performances', PerformanceController::class)->only(['store', 'update', 'destroy']);
        Route::post('performances/{performance}/instagram/link', [PerformanceController::class, 'linkInstagram'])->name('performances.instagram.link');
        Route::delete('performances/{performance}/instagram/link', [PerformanceController::class, 'unlinkInstagram'])->name('performances.instagram.unlink');

        Route::put('settings/legal-pages/{legalPage}', [LegalPageController::class, 'update'])->name('legal-pages.update');
    });

    // --- Super admin only: manage user roles ---

    Route::middleware('super-admin')->group(function () {
        Route::resource('users', UserController::class)->only(['index', 'store', 'update', 'destroy']);

        Route::get('settings/site', [SiteSettingController::class, 'edit'])->name('site-settings.edit');
        Route::put('settings/site', [SiteSettingController::class, 'update'])->name('site-settings.update');
    });
});

Route::get('instagram/oauth/callback', [InstagramController::class, 'callback'])->name('instagram.oauth.callback');

Route::get('privacy-policy', function () {
    return view('legal.show', [
        'page' => LegalPage::where('slug', LegalPage::PRIVACY_POLICY)->firstOrFail(),
    ]);
})->name('legal.privacy-policy');

Route::get('data-deletion', function () {
    return view('legal.show', [
        'page' => LegalPage::where('slug', LegalPage::DATA_DELETION)->firstOrFail(),
    ]);
})->name('legal.data-deletion');
