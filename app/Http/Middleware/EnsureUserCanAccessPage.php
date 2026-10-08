<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserCanAccessPage
{
    /**
     * Handle an incoming request. $page is one of User::PAGES's keys, passed
     * via the route middleware string (e.g. 'can-access:cycles') — this
     * blocks the whole page (and its sibling PDF/Excel/detail/etc. routes)
     * for a user a Super Admin has restricted away from it, independent of
     * their edit-level role.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, string $page): Response
    {
        abort_unless($request->user()?->canAccessPage($page), 403);

        return $next($request);
    }
}
