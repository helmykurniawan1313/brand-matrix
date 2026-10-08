<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PageAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_unrestricted_user_sees_every_page(): void
    {
        $user = User::factory()->create(['role' => User::ROLE_EDITOR, 'page_access' => null]);

        $this->actingAs($user)->get('/cycles')->assertOk();
        $this->actingAs($user)->get('/accounts')->assertOk();
    }

    public function test_restricted_user_is_blocked_from_pages_not_in_their_list(): void
    {
        $user = User::factory()->create(['role' => User::ROLE_EDITOR, 'page_access' => ['accounts']]);

        $this->actingAs($user)->get('/accounts')->assertOk();
        $this->actingAs($user)->get('/cycles')->assertForbidden();
    }

    public function test_super_admin_bypasses_their_own_page_access_restriction(): void
    {
        $admin = User::factory()->create(['role' => User::ROLE_SUPER_ADMIN, 'page_access' => ['accounts']]);

        $this->actingAs($admin)->get('/cycles')->assertOk();
    }
}
