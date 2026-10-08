<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    public const ROLE_VIEWER = 'viewer';

    public const ROLE_EDITOR = 'editor';

    public const ROLE_SUPER_ADMIN = 'super_admin';

    public const ROLES = [self::ROLE_VIEWER, self::ROLE_EDITOR, self::ROLE_SUPER_ADMIN];

    /**
     * Every page a user's visibility can be individually restricted to, keyed
     * by the same string the frontend nav/useAuth check against. Keeping this
     * as the single source of truth (rather than duplicating the list in the
     * Users form) means a new page only needs adding here once.
     */
    public const PAGES = [
        'cycles' => 'Cycles',
        'performances' => 'Performance',
        'accounts' => 'Accounts',
        'views-trend' => 'Views Trend',
        'content-insights' => 'Content Insights',
        'employees' => 'Employees',
        'departments' => 'Departments',
        'score-buckets' => 'Scoring Buckets',
    ];

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'page_access',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'page_access' => 'array',
        ];
    }

    public function hasRole(string $role): bool
    {
        return $this->role === $role;
    }

    public function isViewer(): bool
    {
        return $this->hasRole(self::ROLE_VIEWER);
    }

    public function isEditor(): bool
    {
        return $this->hasRole(self::ROLE_EDITOR);
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole(self::ROLE_SUPER_ADMIN);
    }

    public function canEdit(): bool
    {
        return ! $this->isViewer();
    }

    /**
     * Whether this user can see the given page. page_access === null means
     * unrestricted (sees everything) — the default for every account unless
     * a Super Admin has explicitly opted them into a restricted list. Super
     * Admins always pass regardless of their own page_access value, so
     * restricting a Super Admin's own account (e.g. by mistake) can never
     * lock them out of the Users screen needed to undo it.
     */
    public function canAccessPage(string $page): bool
    {
        if ($this->isSuperAdmin() || $this->page_access === null) {
            return true;
        }

        return in_array($page, $this->page_access, true);
    }
}
