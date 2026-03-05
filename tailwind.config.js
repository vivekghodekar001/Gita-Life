/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
        "./components/**/*.{js,ts,jsx,tsx}",
        "./App.tsx",
        "./index.tsx",
    ],
    theme: {
        extend: {
            colors: {
                background: "var(--background)",
                foreground: "var(--foreground)",
                saffron: {
                    50: '#FFF8EB',
                    100: '#FFEFC7',
                    200: '#FFDB8A',
                    300: '#FFC44D',
                    400: '#FFB020',
                    500: '#F59E0B',
                    600: '#D97706',
                    700: '#B45309',
                    800: '#92400E',
                    900: '#78350F',
                },
                divine: {
                    50: '#F0FDFA',
                    100: '#CCFBF1',
                    200: '#99F6E4',
                    300: '#5EEAD4',
                    400: '#2DD4BF',
                    500: '#14B8A6',
                    600: '#0D9488',
                    700: '#0F766E',
                    800: '#115E59',
                    900: '#134E4A',
                },
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
                serif: ['Playfair Display', 'Georgia', 'serif'],
            },
            animation: {
                'in': 'fadeIn 0.5s cubic-bezier(0.4, 0, 0.2, 1) forwards',
                'slide-in': 'slideInRight 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards',
                'scale-in': 'scaleIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
                'slide-up': 'slideUp 0.5s cubic-bezier(0.4, 0, 0.2, 1) forwards',
                'float': 'float 3s ease-in-out infinite',
                'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
                'spin-slow': 'spin-slow 8s linear infinite',
                'shimmer': 'shimmer 2s linear infinite',
            },
            boxShadow: {
                'divine': '0 4px 14px -2px rgba(15, 118, 110, 0.25)',
                'divine-lg': '0 10px 30px -5px rgba(15, 118, 110, 0.3)',
                'saffron': '0 4px 14px -2px rgba(245, 158, 11, 0.25)',
                'glass': '0 4px 6px -1px rgba(0, 0, 0, 0.04), 0 2px 4px -2px rgba(0, 0, 0, 0.03)',
            },
            backgroundImage: {
                'divine-gradient': 'linear-gradient(135deg, #0F766E 0%, #0D9488 50%, #14B8A6 100%)',
                'saffron-gradient': 'linear-gradient(135deg, #F59E0B 0%, #D97706 50%, #B45309 100%)',
                'dark-gradient': 'linear-gradient(180deg, #0F172A 0%, #1E293B 100%)',
            },
        },
    },
    plugins: [],
}
