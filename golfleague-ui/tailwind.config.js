module.exports = {
  purge: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        notoserif: ["Noto Serif","serif"]
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
