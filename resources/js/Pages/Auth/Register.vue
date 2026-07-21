<script setup>
import { useForm, Link } from '@inertiajs/vue3';
import AuthLayout from '../../Layouts/AuthLayout.vue';

const form = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
});

const submit = () => {
    form.post('/register', {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none';
const inputSurface = 'border-color: var(--border); background-color: var(--surface); color: var(--ink)';
</script>

<template>
    <AuthLayout title="Create your account" subtitle="Start tracking your accounts' health scores.">
        <form @submit.prevent="submit" class="space-y-4">
            <div>
                <label class="block text-sm font-medium" style="color: var(--ink-muted)">Name</label>
                <input
                    v-model="form.name"
                    type="text"
                    autofocus
                    autocomplete="name"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.name }}
                </p>
            </div>

            <div>
                <label class="block text-sm font-medium" style="color: var(--ink-muted)">Email</label>
                <input
                    v-model="form.email"
                    type="email"
                    autocomplete="username"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.email" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.email }}
                </p>
            </div>

            <div>
                <label class="block text-sm font-medium" style="color: var(--ink-muted)">Password</label>
                <input
                    v-model="form.password"
                    type="password"
                    autocomplete="new-password"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.password }}
                </p>
            </div>

            <div>
                <label class="block text-sm font-medium" style="color: var(--ink-muted)">Confirm Password</label>
                <input
                    v-model="form.password_confirmation"
                    type="password"
                    autocomplete="new-password"
                    :class="inputStyle"
                    :style="inputSurface"
                />
                <p v-if="form.errors.password_confirmation" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ form.errors.password_confirmation }}
                </p>
            </div>

            <button
                type="submit"
                :disabled="form.processing"
                class="w-full rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                Create account
            </button>
        </form>

        <p class="mt-6 text-center text-sm" style="color: var(--ink-muted)">
            Already have an account?
            <Link href="/login" class="font-medium" style="color: var(--accent)">Sign in</Link>
        </p>
    </AuthLayout>
</template>
