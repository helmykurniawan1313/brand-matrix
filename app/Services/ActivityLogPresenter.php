<?php

namespace App\Services;

use App\Models\ActivityLog;
use Illuminate\Support\Collection;

/**
 * Shared formatting for a model's activity logs before they're sent to the
 * frontend — resolves foreign-key id values (account_id, project_manager_id,
 * etc.) to a human-readable name, since "104 -> 109" means nothing to someone
 * reading the Activity timeline but "Budi -> Siti" does.
 *
 * Used by every {Resource}Controller::activity() method — PerformanceController,
 * CycleController, WeeklyReportController.
 */
class ActivityLogPresenter
{
    /**
     * @param  Collection<int, ActivityLog>  $logs
     * @param  array<string, class-string<\Illuminate\Database\Eloquent\Model>|\Closure>  $foreignKeyModels  field name (e.g. 'account_id') => model class (resolved via its $displayColumn), or a closure(\Illuminate\Support\Collection $ids): \Illuminate\Support\Collection<int, string> for a model with no simple display column (e.g. Cycle, labeled by date range instead of a 'name' field)
     * @param  string  $displayColumn  the column to show for a plain model-class entry (almost always 'name')
     */
    public static function present(Collection $logs, array $foreignKeyModels, string $displayColumn = 'name'): array
    {
        // Resolve every referenced id in one query per model, rather than one
        // query per changed field per log row. 'created'/'deleted' rows store
        // the field's raw scalar value (the full attribute snapshot), while
        // 'updated' rows store a {old, new} pair for just the changed fields
        // — the two shapes need different id-collection logic.
        $idsByField = [];
        foreach ($logs as $log) {
            foreach ($foreignKeyModels as $field => $resolver) {
                $value = $log->changes[$field] ?? null;
                if ($value === null) {
                    continue;
                }

                if ($log->action === 'updated') {
                    $idsByField[$field][] = $value['old'];
                    $idsByField[$field][] = $value['new'];
                } else {
                    $idsByField[$field][] = $value;
                }
            }
        }

        $namesByFieldAndId = [];
        foreach ($idsByField as $field => $ids) {
            $resolver = $foreignKeyModels[$field];
            $ids = collect($ids)->filter(fn ($id) => $id !== null)->unique()->values();

            $namesByFieldAndId[$field] = $resolver instanceof \Closure
                ? $resolver($ids)
                : $resolver::whereIn('id', $ids)->pluck($displayColumn, 'id');
        }

        return $logs->map(function (ActivityLog $log) use ($foreignKeyModels, $namesByFieldAndId) {
            $changes = $log->changes;

            if ($changes) {
                foreach ($foreignKeyModels as $field => $resolver) {
                    if (! array_key_exists($field, $changes)) {
                        continue;
                    }

                    $names = $namesByFieldAndId[$field] ?? collect();

                    if ($log->action === 'updated') {
                        $changes[$field]['old'] = self::resolveName($names, $changes[$field]['old']);
                        $changes[$field]['new'] = self::resolveName($names, $changes[$field]['new']);
                    } else {
                        $changes[$field] = self::resolveName($names, $changes[$field]);
                    }
                }
            }

            return [
                'id' => $log->id,
                'action' => $log->action,
                'changes' => $changes,
                'user_name' => $log->user?->name,
                'created_at' => $log->created_at->toIso8601String(),
            ];
        })->all();
    }

    private static function resolveName(Collection $names, mixed $id): ?string
    {
        if ($id === null) {
            return null;
        }

        // Falls back to "#<id> (deleted)" rather than silently dropping the
        // value — the referenced Account/Employee row may have since been
        // removed, but the log should still show *something* changed.
        return $names->get($id) ?? "#{$id} (deleted)";
    }
}
