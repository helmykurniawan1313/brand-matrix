<?php

namespace App\Models\Concerns;

use App\Models\ActivityLog;
use Illuminate\Support\Facades\Auth;

/**
 * Records a full before/after history of create/update/delete on any model
 * that `use`s this trait — one ActivityLog row per save, diffing only the
 * fields that actually changed (a resave with no real changes logs nothing).
 *
 * A model can exclude noisy/irrelevant columns from the diff by defining its
 * own `$activityLogExcept` array (e.g. timestamps that aren't already in
 * Eloquent's own $timestamps, or a column that changes on every save for
 * reasons unrelated to user edits).
 */
trait LogsActivity
{
    protected static function bootLogsActivity(): void
    {
        static::created(function ($model) {
            $model->recordActivity('created', $model->attributesToArray());
        });

        static::updated(function ($model) {
            $changes = $model->diffForActivityLog();

            if (! empty($changes)) {
                $model->recordActivity('updated', $changes);
            }
        });

        static::deleted(function ($model) {
            $model->recordActivity('deleted', []);
        });
    }

    protected function diffForActivityLog(): array
    {
        $except = array_merge(
            ['updated_at', 'created_at'],
            $this->activityLogExcept ?? [],
        );

        // getChanges()/getOriginal() return the raw storage representation
        // (e.g. a JSON string for an `array`-cast column), not the cast value
        // — build a clone hydrated with the pre-save attributes so both sides
        // of the diff go through the same cast accessors, instead of "old"
        // being a raw JSON string against "new" being the cast array.
        $original = $this->replicate();
        $original->setRawAttributes($this->getRawOriginal());

        $changes = [];

        foreach (array_keys($this->getChanges()) as $key) {
            if (in_array($key, $except, true)) {
                continue;
            }

            $changes[$key] = [
                'old' => $original->getAttribute($key),
                'new' => $this->getAttribute($key),
            ];
        }

        return $changes;
    }

    protected function recordActivity(string $action, array $changes): void
    {
        ActivityLog::create([
            'loggable_type' => static::class,
            'loggable_id' => $this->getKey(),
            'user_id' => Auth::id(),
            'action' => $action,
            'changes' => $changes ?: null,
        ]);
    }

    public function activityLogs()
    {
        return $this->morphMany(ActivityLog::class, 'loggable')->latest();
    }
}
