<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SiteSettingController extends Controller
{
    public function edit(): Response
    {
        return Inertia::render('Settings/Site', [
            'maintenanceMode' => Setting::isMaintenanceMode(),
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
}
