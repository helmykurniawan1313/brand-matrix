import { computed } from 'vue';
import { usePage } from '@inertiajs/vue3';

export function useAuth() {
    const page = usePage();

    const user = computed(() => page.props.auth?.user ?? null);
    const role = computed(() => user.value?.role ?? null);
    const canEdit = computed(() => role.value !== 'viewer');
    const isSuperAdmin = computed(() => role.value === 'super_admin');

    // null page_access = unrestricted (sees every page) — same default the
    // backend's User::canAccessPage() uses. Super Admins always pass,
    // regardless of their own page_access value.
    const canAccessPage = (pageKey) => {
        if (isSuperAdmin.value) return true;
        const access = user.value?.page_access;
        return access === null || access === undefined || access.includes(pageKey);
    };

    return { user, role, canEdit, isSuperAdmin, canAccessPage };
}
