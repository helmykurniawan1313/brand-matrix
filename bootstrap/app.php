<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->trustProxies(at: '*');

        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
            \App\Http\Middleware\CheckMaintenanceMode::class,
        ]);

        $middleware->alias([
            'can-edit' => \App\Http\Middleware\EnsureUserCanEdit::class,
            'super-admin' => \App\Http\Middleware\EnsureUserIsSuperAdmin::class,
        ]);

        // Laravel's default middleware priority list reorders middleware that share
        // a route by priority class, not registration order — so appending
        // CheckMaintenanceMode to the web group isn't enough; without an explicit
        // priority entry, Authenticate ('auth') still runs first and redirects a
        // logged-out visitor to /login before this middleware ever sees the request.
        // It has to run after StartSession (so $request->user() can resolve, for the
        // super-admin bypass) but before Authenticate (so it intercepts before the
        // login redirect fires).
        $middleware->priority([
            \Illuminate\Cookie\Middleware\EncryptCookies::class,
            \Illuminate\Session\Middleware\StartSession::class,
            \App\Http\Middleware\CheckMaintenanceMode::class,
            \Illuminate\Auth\Middleware\Authenticate::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Renders a proper Inertia/Vue 404 page instead of Laravel's default
        // Blade error view, so an unmatched route stays inside the app's own
        // layout/theme rather than dropping to a bare unstyled error page.
        $exceptions->respond(function (\Symfony\Component\HttpFoundation\Response $response, \Throwable $exception, Request $request) {
            if ($response->getStatusCode() === 404 && ! $request->expectsJson()) {
                return \Inertia\Inertia::render('Errors/NotFound')
                    ->toResponse($request)
                    ->setStatusCode(404);
            }

            return $response;
        });
    })->create();
