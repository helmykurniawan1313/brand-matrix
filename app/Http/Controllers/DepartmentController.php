<?php

namespace App\Http\Controllers;

use App\Models\Department;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DepartmentController extends Controller
{
    public function index(Request $request): Response
    {
        return Inertia::render('Departments/Index', [
            'departments' => Department::orderBy('name')
                ->paginate(15)
                ->withQueryString(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:departments,name'],
        ]);

        Department::create($data);

        return back();
    }

    public function update(Request $request, Department $department): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:departments,name,'.$department->id],
        ]);

        $department->update($data);

        return back();
    }

    public function destroy(Department $department): RedirectResponse
    {
        $department->delete();

        return back();
    }
}
