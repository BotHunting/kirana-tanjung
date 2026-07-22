/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./script/**/*.html", // Memindai semua file HTML di dalam folder 'script'
  ],
  theme: {
    extend: {
      // Menambahkan font weight kustom yang digunakan di proyek
      fontWeight: {
        '800': '800',
      },
      // Anda juga bisa mendefinisikan warna kustom dari :root di sini
      colors: {
        primary: '#2563eb',
        accent: '#7c3aed',
      }
    },
  },
  plugins: [],
}