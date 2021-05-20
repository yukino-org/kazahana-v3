const colors = require("tailwindcss/colors");

module.exports = {
    purge: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx,css}"],
    darkMode: "class",
    theme: {
        fontFamily: {
            sans: ["Poppins", "sans-serif"],
        },
        extend: {
            colors: {
                gray: colors.gray,
                indigo: colors.indigo,
            },
        },
    },
    variants: {
        extend: {},
    },
    plugins: [],
};
