/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Paleta inspirada no planner de papel (bege/creme) do design de referência.
        // Mantém o mesmo espectro já usado no app, só com mais variações de profundidade.
        papel: {
          claro: '#faf4e6',
          DEFAULT: '#f2ead9',
          escuro: '#e4d6b8',
        },
        tinta: {
          DEFAULT: '#2f2a24',
          suave: '#6b6255',
          fraca: '#9a9082',
        },
        // Cada seção do app tem uma cor de destaque própria (mesmo espectro pastel),
        // usada para reforçar a navegação e diferenciar as áreas visualmente.
        destaque: {
          azul: { claro: '#e3f0f7', DEFAULT: '#8fb9d6', escuro: '#5a8fb0' },
          verde: { claro: '#e9f2e3', DEFAULT: '#9dc191', escuro: '#6b9a5c' },
          rosa: { claro: '#f7e9ec', DEFAULT: '#dd9ba8', escuro: '#c06d80' },
          areia: { claro: '#f3e9d6', DEFAULT: '#cba86b', escuro: '#a3803f' },
          roxo: { claro: '#ece5f2', DEFAULT: '#a98fc2', escuro: '#7c5e9c' },
        },
      },
      fontFamily: {
        titulo: ['"Caveat"', 'cursive'],
        corpo: ['"Nunito"', 'sans-serif'],
        manuscrito: ['"Kalam"', 'cursive'], // fonte com traço à mão, usada no diário
      },
      boxShadow: {
        // Sombra suave e quente, como uma folha de papel levemente elevada.
        papel: '0 2px 10px -2px rgba(47, 42, 36, 0.12), 0 1px 2px rgba(47, 42, 36, 0.06)',
        'papel-lg': '0 8px 24px -6px rgba(47, 42, 36, 0.18), 0 2px 6px rgba(47, 42, 36, 0.08)',
      },
    },
  },
  plugins: [],
}
