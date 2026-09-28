/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Paleta inspirada no planner de papel (bege/creme) do design de referência.
        // Os valores reais ficam em variáveis CSS (src/index.css), trocadas pela
        // classe .dark no <html> — assim o mesmo token (ex: bg-papel) serve os dois temas.
        papel: {
          claro: 'rgb(var(--papel-claro) / <alpha-value>)',
          DEFAULT: 'rgb(var(--papel) / <alpha-value>)',
          escuro: 'rgb(var(--papel-escuro) / <alpha-value>)',
        },
        tinta: {
          DEFAULT: 'rgb(var(--tinta) / <alpha-value>)',
          suave: 'rgb(var(--tinta-suave) / <alpha-value>)',
          fraca: 'rgb(var(--tinta-fraca) / <alpha-value>)',
        },
        // Cada seção do app tem uma cor de destaque própria (mesmo espectro pastel),
        // usada para reforçar a navegação e diferenciar as áreas visualmente.
        destaque: {
          azul: {
            claro: 'rgb(var(--destaque-azul-claro) / <alpha-value>)',
            DEFAULT: 'rgb(var(--destaque-azul) / <alpha-value>)',
            escuro: 'rgb(var(--destaque-azul-escuro) / <alpha-value>)',
          },
          verde: {
            claro: 'rgb(var(--destaque-verde-claro) / <alpha-value>)',
            DEFAULT: 'rgb(var(--destaque-verde) / <alpha-value>)',
            escuro: 'rgb(var(--destaque-verde-escuro) / <alpha-value>)',
          },
          rosa: {
            claro: 'rgb(var(--destaque-rosa-claro) / <alpha-value>)',
            DEFAULT: 'rgb(var(--destaque-rosa) / <alpha-value>)',
            escuro: 'rgb(var(--destaque-rosa-escuro) / <alpha-value>)',
          },
          areia: {
            claro: 'rgb(var(--destaque-areia-claro) / <alpha-value>)',
            DEFAULT: 'rgb(var(--destaque-areia) / <alpha-value>)',
            escuro: 'rgb(var(--destaque-areia-escuro) / <alpha-value>)',
          },
          roxo: {
            claro: 'rgb(var(--destaque-roxo-claro) / <alpha-value>)',
            DEFAULT: 'rgb(var(--destaque-roxo) / <alpha-value>)',
            escuro: 'rgb(var(--destaque-roxo-escuro) / <alpha-value>)',
          },
        },
      },
      fontFamily: {
        titulo: ['"Caveat"', 'cursive'],
        corpo: ['"Nunito"', 'sans-serif'],
        manuscrito: ['"Kalam"', 'cursive'], // fonte com traço à mão, usada no diário
      },
      boxShadow: {
        // Sombra suave e quente, como uma folha de papel levemente elevada.
        // No escuro vira um contorno bem sutil (sombra preta não aparece sobre preto).
        papel: 'var(--shadow-papel)',
        'papel-lg': 'var(--shadow-papel-lg)',
      },
    },
  },
  plugins: [],
}
