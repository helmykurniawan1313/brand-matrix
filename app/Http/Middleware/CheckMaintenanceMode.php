<?php

namespace App\Http\Middleware;

use App\Models\Setting;
use Closure;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Symfony\Component\HttpFoundation\Response;

class CheckMaintenanceMode
{
    /**
     * When maintenance mode is on, every request from a non-super-admin (including
     * logged-out visitors) is served the under-construction page instead of the
     * real app. Super admins pass through untouched, so they can flip it back off.
     * The settings/legal/login/logout routes stay reachable so a super admin can
     * still sign in to turn maintenance off, and the legal pages required for app
     * store review remain visible.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! Setting::isMaintenanceMode()) {
            return $next($request);
        }

        if ($request->user()?->isSuperAdmin()) {
            return $next($request);
        }

        $exempt = ['login', 'logout', 'privacy-policy', 'data-deletion'];
        if (in_array($request->path(), $exempt, true) || str_starts_with($request->path(), 'instagram/oauth')) {
            return $next($request);
        }

        return Inertia::render('MaintenanceMode')->toResponse($request)->setStatusCode(503);
    }
}
