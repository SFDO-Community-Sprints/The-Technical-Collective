module.exports = {
  content: [
    './prototype/**/*.html',
    './prototype/assets/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        brand: { DEFAULT: '#3f51b5', dark: '#303f9f', light: '#5c6bc0' },
        accent: { DEFAULT: '#00bcd4', dark: '#0097a7' }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif']
      }
    }
  }
};
