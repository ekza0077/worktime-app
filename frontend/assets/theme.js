// =====================================================================
// เวลางาน — Tailwind theme (extracted จากไฟล์ดีไซน์ต้นฉบับ)
// =====================================================================
window.__WT_TAILWIND__ = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "surface":                   "#f8faf6",
        "surface-bright":            "#f8faf6",
        "surface-dim":               "#d8dbd7",
        "surface-container-lowest":  "#ffffff",
        "surface-container-low":     "#f2f4f0",
        "surface-container":         "#eceeea",
        "surface-container-high":    "#e7e9e5",
        "surface-container-highest": "#e1e3df",
        "surface-variant":           "#e1e3df",
        "background":                "#f8faf6",
        "on-surface":                "#191c1a",
        "on-surface-variant":        "#404943",
        "outline":                   "#707973",
        "outline-variant":           "#bfc9c1",
        "primary":                   "#0f5238",
        "primary-container":         "#2d6a4f",
        "primary-fixed":             "#b1f0ce",
        "primary-fixed-dim":         "#95d4b3",
        "on-primary":                "#ffffff",
        "on-primary-container":      "#a8e7c5",
        "secondary":                 "#0060a8",
        "secondary-container":       "#47a1ff",
        "secondary-fixed":           "#d3e4ff",
        "on-secondary":              "#ffffff",
        "on-secondary-container":    "#003663",
        "tertiary":                  "#5d4300",
        "tertiary-container":        "#7a5a00",
        "tertiary-fixed":            "#ffdfa0",
        "tertiary-fixed-dim":        "#fbbc00",
        "on-tertiary":               "#ffffff",
        "on-tertiary-fixed-variant": "#5c4300",
        "error":                     "#ba1a1a",
        "error-container":           "#ffdad6",
        "on-error":                  "#ffffff",
        "on-error-container":        "#93000a",
        "inverse-primary":           "#95d4b3",
        "inverse-surface":           "#2e312f",
        "inverse-on-surface":        "#eff1ed",
      },
      borderRadius: { DEFAULT: "1rem", lg: "2rem", xl: "3rem", full: "9999px" },
      fontFamily: {
        headline: ["Plus Jakarta Sans", "Anuphan"],
        body:     ["Inter", "IBM Plex Sans Thai"],
        label:    ["Inter", "IBM Plex Sans Thai"],
      },
    },
  },
};

// apply when tailwind is ready
window.addEventListener("DOMContentLoaded", () => {
  if (window.tailwind) window.tailwind.config = window.__WT_TAILWIND__;
});
