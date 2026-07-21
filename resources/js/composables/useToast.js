import { ref } from 'vue';

const toasts = ref([]);
let nextId = 1;

const push = (message, type = 'success', duration = 3500) => {
    const id = nextId++;
    toasts.value.push({ id, message, type });
    setTimeout(() => dismiss(id), duration);
    return id;
};

const dismiss = (id) => {
    toasts.value = toasts.value.filter((t) => t.id !== id);
};

export function useToast() {
    return {
        toasts,
        success: (message) => push(message, 'success'),
        error: (message) => push(message, 'error'),
        dismiss,
    };
}
