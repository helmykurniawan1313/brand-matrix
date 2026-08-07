import { computed } from 'vue';
import { usePage } from '@inertiajs/vue3';

export function useAuth() {
    const page = usePage();

    const user = computed(() => page.props.auth?.user ?? null);
    const role = computed(() => user.value?.role ?? null);
    const canEdit = computed(() => role.value !== 'viewer');
    const isSuperAdmin = computed(() => role.value === 'super_admin');

    return { user, role, canEdit, isSuperAdmin };
}
