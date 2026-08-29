<script setup>
import { useForm, Link } from '@inertiajs/vue3';
import AuthLayout from '../../Layouts/AuthLayout.vue';

defineProps({
    status: { type: String, default: null },
});

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post('/login', {
        onFinish: () => form.reset('password'),
    });
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none';
const inputSurface = 'border-color: var(--border); background-color: var(--surface); color: var(--ink)';
</script>

<template>
    <AuthLayout title="Sign in to Brand Matrix" subtitle="Track growth, visibility, and engagement scores.">
        <div v-if="status" class="mb-4 rounded-md px-3 py-2 text-sm" style="background-color: var(--accent-soft); color: var(--accent)">
            {{ status }}
        </div>

        <form @submit.prevent="submit" class="space-y-4">
            <div>
                <label class="block text-sm font-medium" style="color: var(--ink-muted)">Email</label>
                <input
                    v-model="form.email"
                    type="email"
                    autofocus
                    autocomplete="username"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.email" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.email }}
                </p>
            </div>

            <div>
                <div class="flex items-center justify-between">
                    <label class="block text-sm font-medium" style="color: var(--ink-muted)">Password</label>
                    <Link href="/forgot-password" class="text-sm font-medium" style="color: var(--accent)">
                        Forgot password?
                    </Link>
                </div>
                <input
                    v-model="form.password"
                    type="password"
                    autocomplete="current-password"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.password }}
                </p>
            </div>

            <label class="flex items-center gap-2 text-sm" style="color: var(--ink-muted)">
                <input v-model="form.remember" type="checkbox" class="rounded" style="accent-color: var(--accent)" />
                Remember me
            </label>

            <button
                type="submit"
                :disabled="form.processing"
                class="w-full rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                Sign in
            </button>
        </form>
    </AuthLayout>
</template>
