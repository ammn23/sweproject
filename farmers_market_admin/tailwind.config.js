module.exports = {
  mode: "jit",
  content: [
    "./src/**/*.{js,ts,jsx,tsx,html,mdx}",
    "./src/**/**/*.{js,ts,jsx,tsx,html,mdx}",
  ],
  darkMode: "class",
  theme: {
    screens: {
      md: { max: "1050px" },
      sm: { max: "550px" },
    },
    extend: {
      colors: {
        black: { 900: "var(--black_900)" },
        blue_gray: { 100: "var(--blue_gray_100)" },
        gray: { 400: "var(--gray_400)" },
        light_green: { 200: "var(--light_green_200)" },
        teal: { 800: "var(--teal_800)" },
        white: { a700: "var(--white_a700)" },
      },
      boxShadow: {},
      fontFamily: {
        inriasans: "Inria Sans",
        inriaserif: "Inria Serif",
      },
      textShadow: {
        ts: "0px 4px 4px #000000",
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
