<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LegalPage extends Model
{
    protected $fillable = [
        'slug',
        'title',
        'content_html',
    ];

    public const PRIVACY_POLICY = 'privacy-policy';

    public const DATA_DELETION = 'data-deletion';
}
