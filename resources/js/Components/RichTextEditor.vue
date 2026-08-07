<script setup>
import { onBeforeUnmount, watch } from 'vue';
import { useEditor, EditorContent } from '@tiptap/vue-3';
import StarterKit from '@tiptap/starter-kit';
import Link from '@tiptap/extension-link';

const props = defineProps({
    modelValue: {
        type: String,
        default: '',
    },
});

const emit = defineEmits(['update:modelValue']);

const editor = useEditor({
    content: props.modelValue,
    extensions: [
        StarterKit.configure({ heading: { levels: [2, 3] } }),
        Link.configure({ openOnClick: false, autolink: true }),
    ],
    onUpdate: ({ editor }) => emit('update:modelValue', editor.getHTML()),
});

watch(
    () => props.modelValue,
    (value) => {
        if (editor.value && value !== editor.value.getHTML()) {
            editor.value.commands.setContent(value, false);
        }
    }
);

onBeforeUnmount(() => editor.value?.destroy());

const setLink = () => {
    const previousUrl = editor.value.getAttributes('link').href;
    const url = window.prompt('Link URL', previousUrl ?? 'https://');

    if (url === null) return;

    if (url === '') {
        editor.value.chain().focus().extendMarkRange('link').unsetLink().run();
        return;
    }

    editor.value.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
};

const toolbarButtonStyle = (active) =>
    `rounded px-2 py-1 text-xs font-semibold transition-colors ${active ? '' : 'hover:opacity-70'}`;
</script>

<template>
    <div class="rounded-md border" style="border-color: var(--border)">
        <div v-if="editor" class="flex flex-wrap items-center gap-1 border-b p-1.5" style="border-color: var(--border)">
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('bold'))"
                :style="editor.isActive('bold') ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleBold().run()"
            >
                Bold
            </button>
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('italic'))"
                :style="editor.isActive('italic') ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleItalic().run()"
            >
                Italic
            </button>
            <span class="mx-1 h-4 w-px" style="background-color: var(--border)" />
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('heading', { level: 2 }))"
                :style="editor.isActive('heading', { level: 2 }) ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
            >
                H2
            </button>
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('heading', { level: 3 }))"
                :style="editor.isActive('heading', { level: 3 }) ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleHeading({ level: 3 }).run()"
            >
                H3
            </button>
            <span class="mx-1 h-4 w-px" style="background-color: var(--border)" />
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('bulletList'))"
                :style="editor.isActive('bulletList') ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleBulletList().run()"
            >
                Bullet List
            </button>
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('orderedList'))"
                :style="editor.isActive('orderedList') ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="editor.chain().focus().toggleOrderedList().run()"
            >
                Numbered List
            </button>
            <span class="mx-1 h-4 w-px" style="background-color: var(--border)" />
            <button
                type="button"
                :class="toolbarButtonStyle(editor.isActive('link'))"
                :style="editor.isActive('link') ? 'background-color: var(--accent-soft); color: var(--accent)' : 'color: var(--ink-muted)'"
                @click="setLink"
            >
                Link
            </button>
        </div>
        <EditorContent :editor="editor" class="prose-editor px-3 py-2.5 text-sm" style="color: var(--ink)" />
    </div>
</template>

<style>
.prose-editor .ProseMirror {
    outline: none;
    min-height: 12rem;
}
.prose-editor .ProseMirror p {
    margin-bottom: 0.75em;
}
.prose-editor .ProseMirror h2 {
    font-size: 1.1rem;
    font-weight: 700;
    margin-top: 1.25em;
    margin-bottom: 0.4em;
}
.prose-editor .ProseMirror h3 {
    font-size: 1rem;
    font-weight: 700;
    margin-top: 1em;
    margin-bottom: 0.35em;
}
.prose-editor .ProseMirror ul,
.prose-editor .ProseMirror ol {
    padding-left: 1.25rem;
    margin-bottom: 0.75em;
}
.prose-editor .ProseMirror a {
    color: var(--accent);
    text-decoration: underline;
}
</style>
