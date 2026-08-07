<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;
use Inertia\Response;

class UserController extends Controller
{
    public function index(Request $request): Response
    {
        return Inertia::render('Users/Index', [
            'users' => User::orderBy('name')->paginate(15)->withQueryString(),
            'roles' => User::ROLES,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', 'string', 'in:'.implode(',', User::ROLES)],
        ]);

        User::create([
            ...$data,
            'password' => Hash::make($data['password']),
        ]);

        return back();
    }

    public function update(Request $request, User $user): RedirectResponse
    {
        $data = $request->validate([
            'role' => ['required', 'string', 'in:'.implode(',', User::ROLES)],
        ]);

        if ($user->id === $request->user()->id && $data['role'] !== User::ROLE_SUPER_ADMIN) {
            return back()->withErrors(['role' => 'You cannot change your own role away from Super Admin.']);
        }

        $user->update($data);

        return back();
    }

    public function destroy(Request $request, User $user): RedirectResponse
    {
        if ($user->id === $request->user()->id) {
            return back()->withErrors(['role' => 'You cannot delete your own account.']);
        }

        $user->delete();

        return back();
    }
}
