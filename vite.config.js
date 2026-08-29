import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
        tailwindcss(),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
                compilerOptions: {
                    // dotlottie-wc is a native web component (from @lottiefiles/dotlottie-wc),
                    // not a Vue component — without this, Vue's compiler treats the tag as
                    // unknown and warns/may not initialize it as a real custom element.
                    isCustomElement: (tag) => tag === 'dotlottie-wc',
                },
            },
        }),
    ],
    server: {
        watch: {
            ignored: ['**/storage/framework/views/**'],
        },
    },
});
