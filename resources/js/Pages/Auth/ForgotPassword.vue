<script setup>
import { useForm, Link } from '@inertiajs/vue3';
import AuthLayout from '../../Layouts/AuthLayout.vue';

defineProps({
    status: { type: String, default: null },
});

const form = useForm({
    email: '',
});

const submit = () => {
    form.post('/forgot-password');
};

const inputStyle =
    'mt-1 w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none';
const inputSurface = 'border-color: var(--border); background-color: var(--surface); color: var(--ink)';
</script>

<template>
    <AuthLayout title="Forgot your password?" subtitle="We'll email you a link to reset it.">
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

            <button
                type="submit"
                :disabled="form.processing"
                class="w-full rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                Email password reset link
            </button>
        </form>

        <p class="mt-6 text-center text-sm" style="color: var(--ink-muted)">
            <Link href="/login" class="font-medium" style="color: var(--accent)">Back to sign in</Link>
        </p>
    </AuthLayout>
</template>
