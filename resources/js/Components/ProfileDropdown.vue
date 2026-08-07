<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { Link, router, useForm } from '@inertiajs/vue3';

const props = defineProps({
    user: {
        type: Object,
        required: true,
    },
});

const roleLabels = {
    viewer: 'Viewer',
    editor: 'Editor',
    super_admin: 'Super Admin',
};

const initials = () => {
    return props.user.name
        .split(' ')
        .map((part) => part[0])
        .slice(0, 2)
        .join('')
        .toUpperCase();
};

const showMenu = ref(false);
const showEditModal = ref(false);
const containerRef = ref(null);

const toggleMenu = () => {
    showMenu.value = !showMenu.value;
};

const closeMenu = () => {
    showMenu.value = false;
};

const onClickOutside = (event) => {
    if (containerRef.value && !containerRef.value.contains(event.target)) {
        showMenu.value = false;
    }
};

onMounted(() => document.addEventListener('click', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutside));

const editTab = ref('profile');

const openEdit = () => {
    closeMenu();
    editTab.value = 'profile';
    profileForm.name = props.user.name;
    profileForm.email = props.user.email;
    profileForm.clearErrors();
    passwordForm.reset();
    passwordForm.clearErrors();
    showEditModal.value = true;
};

const closeEdit = () => {
    showEditModal.value = false;
};

const profileForm = useForm({
    name: props.user.name,
    email: props.user.email,
});

const submitProfile = () => {
    profileForm.put('/user/profile-information', {
        preserveScroll: true,
        errorBag: 'updateProfileInformation',
    });
};

const passwordForm = useForm({
    current_password: '',
    password: '',
    password_confirmation: '',
});

const submitPassword = () => {
    passwordForm.put('/user/password', {
        preserveScroll: true,
        errorBag: 'updatePassword',
        onSuccess: () => passwordForm.reset(),
    });
};

const logout = () => {
    closeMenu();
    router.post('/logout');
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none focus:ring-2';
</script>

<template>
    <div ref="containerRef" class="relative">
        <button
            type="button"
            class="flex items-center gap-2 rounded-md px-2 py-1.5 text-sm font-medium transition-colors hover:opacity-80"
            style="color: var(--ink)"
            @click="toggleMenu"
        >
            <span
                class="flex h-7 w-7 items-center justify-center rounded-full text-xs font-bold"
                style="background-color: var(--accent-soft); color: var(--accent)"
            >
                {{ initials() }}
            </span>
            <span>{{ user.name }}</span>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-3.5 w-3.5" style="color: var(--ink-faint)">
                <path d="m6 9 6 6 6-6" />
            </svg>
        </button>

        <div
            v-if="showMenu"
            class="absolute right-0 z-20 mt-2 w-48 overflow-hidden rounded-md border shadow-lg"
            style="border-color: var(--border); background-color: var(--surface-raised)"
        >
            <div v-if="user.role" class="border-b px-4 py-2" style="border-color: var(--border)">
                <span
                    class="inline-flex items-center rounded px-1.5 py-0.5 text-[11px] font-semibold uppercase tracking-wide"
                    style="background-color: var(--accent-soft); color: var(--accent)"
                >
                    {{ roleLabels[user.role] ?? user.role }}
                </span>
            </div>
            <button
                type="button"
                class="block w-full px-4 py-2.5 text-left text-sm font-medium transition-colors hover:opacity-70"
                style="color: var(--ink)"
                @click="openEdit"
            >
                Edit Profile
            </button>
            <Link
                href="/settings/legal-pages"
                class="block w-full border-t px-4 py-2.5 text-left text-sm font-medium transition-colors hover:opacity-70"
                style="border-color: var(--border); color: var(--ink)"
                @click="closeMenu"
            >
                Legal Pages
            </Link>
            <button
                type="button"
                class="block w-full border-t px-4 py-2.5 text-left text-sm font-medium transition-colors hover:opacity-70"
                style="border-color: var(--border); color: var(--status-parah-ink)"
                @click="logout"
            >
                Sign out
            </button>
        </div>

        <div
            v-if="showEditModal"
            class="fixed inset-0 z-30 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        >
            <div
                class="w-full max-w-md rounded-lg border shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex items-start justify-between gap-4 px-6 pt-6">
                    <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Edit Profile</h2>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="closeEdit"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="mt-4 flex gap-1 border-b px-6" style="border-color: var(--border)">
                    <button
                        type="button"
                        class="border-b-2 px-1 py-2.5 text-sm font-medium transition-colors"
                        :style="
                            editTab === 'profile'
                                ? 'border-color: var(--accent); color: var(--accent)'
                                : 'border-color: transparent; color: var(--ink-muted)'
                        "
                        @click="editTab = 'profile'"
                    >
                        Profile
                    </button>
                    <button
                        type="button"
                        class="ml-4 border-b-2 px-1 py-2.5 text-sm font-medium transition-colors"
                        :style="
                            editTab === 'password'
                                ? 'border-color: var(--accent); color: var(--accent)'
                                : 'border-color: transparent; color: var(--ink-muted)'
                        "
                        @click="editTab = 'password'"
                    >
                        Password
                    </button>
                </div>

                <form v-if="editTab === 'profile'" @submit.prevent="submitProfile" class="space-y-4 px-6 py-6">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Name</label>
                        <input
                            v-model="profileForm.name"
                            type="text"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                        <p v-if="profileForm.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ profileForm.errors.name }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Email</label>
                        <input
                            v-model="profileForm.email"
                            type="email"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                        <p v-if="profileForm.errors.email" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ profileForm.errors.email }}
                        </p>
                    </div>
                    <div class="flex justify-end pt-2">
                        <button
                            type="submit"
                            :disabled="profileForm.processing"
                            class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                            style="background-color: var(--accent); color: var(--accent-ink)"
                        >
                            Save Profile
                        </button>
                    </div>
                </form>

                <form v-else @submit.prevent="submitPassword" class="space-y-4 px-6 py-6">
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Current Password</label>
                        <input
                            v-model="passwordForm.current_password"
                            type="password"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                        <p v-if="passwordForm.errors.current_password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ passwordForm.errors.current_password }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">New Password</label>
                        <input
                            v-model="passwordForm.password"
                            type="password"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                        <p v-if="passwordForm.errors.password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                            {{ passwordForm.errors.password }}
                        </p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium" style="color: var(--ink-muted)">Confirm New Password</label>
                        <input
                            v-model="passwordForm.password_confirmation"
                            type="password"
                            :class="inputStyle"
                            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                        />
                    </div>
                    <div class="flex justify-end pt-2">
                        <button
                            type="submit"
                            :disabled="passwordForm.processing"
                            class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                            style="background-color: var(--accent); color: var(--accent-ink)"
                        >
                            Update Password
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
