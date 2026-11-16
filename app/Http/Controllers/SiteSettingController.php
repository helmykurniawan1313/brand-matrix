<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;

class SiteSettingController extends Controller
{
    public function edit(): Response
    {
        $faviconPath = Setting::get(Setting::FAVICON_PATH);

        return Inertia::render('Settings/Site', [
            'maintenanceMode' => Setting::isMaintenanceMode(),
            'faviconUrl' => $faviconPath ? Storage::disk('public')->url($faviconPath) : null,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'maintenance_mode' => ['required', 'boolean'],
        ]);

        Setting::set(Setting::MAINTENANCE_MODE, $data['maintenance_mode'] ? '1' : '0');

        return back();
    }

    public function updateFavicon(Request $request): RedirectResponse
    {
        $data = $request->validate([
            // .ico explicitly allowed via mimetypes — Laravel's `image` rule
            // doesn't recognize it as a valid image MIME type, and browsers
            // still favor .ico for favicons over svg/png in some contexts.
            'favicon' => ['required', 'file', 'mimetypes:image/x-icon,image/vnd.microsoft.icon,image/png,image/svg+xml,image/jpeg', 'max:512'],
        ]);

        $oldPath = Setting::get(Setting::FAVICON_PATH);
        if ($oldPath) {
            Storage::disk('public')->delete($oldPath);
        }

        $path = $data['favicon']->store('site', 'public');
        Setting::set(Setting::FAVICON_PATH, $path);

        return back();
    }

    public function destroyFavicon(): RedirectResponse
    {
        $path = Setting::get(Setting::FAVICON_PATH);

        if ($path) {
            Storage::disk('public')->delete($path);
            Setting::set(Setting::FAVICON_PATH, '');
        }

        return back();
    }
}
