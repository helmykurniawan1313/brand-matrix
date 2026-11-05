import { watch, onBeforeUnmount } from 'vue';

// Closes a modal on Escape — applies to every modal (forms included): Esc is
// a deliberate keypress, not an accidental stray click, so it doesn't carry
// the same data-loss risk that backdrop-click-to-close does (see CLAUDE.md's
// modal UI pattern for the backdrop-click split between form/non-form).
//
// `isOpen` is a ref/getter (or a plain boolean for always-mounted components
// like ConfirmDialog, which toggle visibility via a prop instead of v-if).
// `onClose` is called once per Escape press while open; it's up to the
// caller's own close handler to reset any draft state, same as the X button.
export function useEscapeKey(isOpen, onClose) {
    const handler = (event) => {
        if (event.key !== 'Escape') return;
        const open = typeof isOpen === 'function' ? isOpen() : isOpen.value ?? isOpen;
        if (open) onClose();
    };

    document.addEventListener('keydown', handler);
    onBeforeUnmount(() => document.removeEventListener('keydown', handler));
}
