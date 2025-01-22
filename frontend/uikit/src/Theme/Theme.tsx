import type { ReactNode } from "react";
import { createContext, useContext, useState } from "react";

// The Liquity V2 base color palette, meant
// to be used by themes rather than directly.
export const colors = {
  // Blue
  "blue:50":  "#E4F1FF",
  "blue:100": "#BCDFFF",
  "blue:200": "#95CEFF",
  "blue:300": "#2C8CFD",
  "blue:400": "#137EFC",
  "blue:500": "#036EEE",
  "blue:600": "#025DCA",
  "blue:700": "#024BA1",
  "blue:800": "#033674",
  "blue:900": "#022146",
  "blue:950": "#010B17",

  // Gray (Cream Range)
  // Light creams for backgrounds + slightly darker creams
  // for containers
  "gray:50":  "#F9F2E7",
  "gray:100": "#F5E9DB",
  "gray:200": "#F2E2D2",
  "gray:300": "#EBD6C1",
  "gray:400": "#E2C7AA",
  "gray:500": "#D7B890",
  "gray:600": "#C8A777",
  "gray:700": "#B59764",
  "gray:800": "#9E8054",
  "gray:900": "#8A6E49",

  // Make 950 a near-black or very deep brown
  // for strong text contrast
  "gray:950": "#2B2B2B",

  // Yellow
  "yellow:50": "#FDFBE9",
  "yellow:100": "#FCF8C5",
  "yellow:200": "#FAEE8E",
  "yellow:300": "#F5D93A",
  "yellow:400": "#F1C91E",
  "yellow:500": "#E1B111",
  "yellow:600": "#C2890C",
  "yellow:700": "#9B620D",
  "yellow:800": "#804E13",
  "yellow:900": "#6D4016",
  "yellow:950": "#402108",

  // Green
  "green:50": "#F1FCF2",
  "green:100": "#DEFAE4",
  "green:200": "#BFF3CA",
  "green:300": "#8EE7A1",
  "green:400": "#63D77D",
  "green:500": "#2EB94D",
  "green:600": "#20993C",
  "green:700": "#1D7832",
  "green:800": "#1C5F2C",
  "green:900": "#194E27",
  "green:950": "#082B12",

  // Red
  "red:50": "#FEF5F2",
  "red:100": "#FFE7E1",
  "red:200": "#FFD5C9",
  "red:300": "#FEB7A3",
  "red:400": "#FB7C59",
  "red:500": "#F36740",
  "red:600": "#E14A21",
  "red:700": "#BD3C18",
  "red:800": "#9C3518",
  "red:900": "#82301A",
  "red:950": "#471608",

  // brown
  "brown:50": "#F8F6F4",

  // desert
  "desert:50": "#FAF9F7",
  "desert:100": "#EFECE5",
  "desert:950": "#2C231E",

  // White (your default background color)
  // If you prefer a different shade for the main
  // background, tweak this
  "white": "#F8F0E3",

  // Brand colors
  "brand:blue": "#036EEE",
  "brand:lightBlue": "#2C8CFD",
  "brand:darkBlue": "#022146",
  "brand:green": "#63D77D",
  "brand:golden": "#F5D93A",
  "brand:cyan": "#95CBF3",
  "brand:coral": "#FB7C59",
  "brand:brown": "#DBB79B",
};

// The light theme, used by components via useTheme()
export const lightTheme = {
  name: "light" as const,
  colors: {
    accent: "blue:500",
    accentActive: "blue:600",
    accentContent: "white",
    accentHint: "blue:400",

    // Make your entire app background “white” -> #F8F0E3
    background: "white",
    backgroundActive: "gray:50",

    border: "gray:200",
    borderSoft: "gray:100",

    // The big change: let normal text use near-black
    // for strong contrast on cream.
    content: "gray:950",

    // Use a slightly lighter color for secondary text
    contentAlt: "gray:800",
    contentAlt2: "gray:700",

    controlBorder: "gray:300",
    controlBorderStrong: "blue:950",
    controlSurface: "white",
    controlSurfaceAlt: "gray:200",

    hint: "brown:50",
    infoSurface: "desert:50",
    infoSurfaceBorder: "desert:100",
    infoSurfaceContent: "desert:950",

    dimmed: "gray:500",
    fieldBorder: "gray:100",
    fieldBorderFocused: "gray:300",
    fieldSurface: "gray:50",

    focused: "blue:500",
    focusedSurface: "blue:50",
    focusedSurfaceActive: "blue:100",

    // For your nav or strong cards:
    strongSurface: "blue:900",
    strongSurfaceContent: "white",
    strongSurfaceContentAlt: "gray:100",
    strongSurfaceContentAlt2: "gray:50",

    interactive: "blue:950",

    negative: "red:500",
    negativeStrong: "red:600",
    negativeActive: "red:600",
    negativeContent: "white",
    negativeHint: "red:400",
    negativeSurface: "red:50",
    negativeSurfaceBorder: "red:100",
    negativeSurfaceContent: "red:900",
    negativeSurfaceContentAlt: "red:400",

    positive: "green:500",
    positiveAlt: "green:400",
    positiveActive: "green:600",
    positiveContent: "white",
    positiveHint: "green:400",

    secondary: "blue:50",
    secondaryActive: "blue:200",
    secondaryContent: "blue:500",
    secondaryHint: "blue:100",

    selected: "blue:500",
    separator: "gray:50",
    surface: "white",
    tableBorder: "gray:100",

    warning: "yellow:400",
    disabledBorder: "gray:200",
    disabledContent: "gray:500",
    disabledSurface: "gray:50",

    brandBlue: "brand:blue",
    brandBlueContent: "white",
    brandBlueContentAlt: "blue:50",
    brandDarkBlue: "brand:darkBlue",
    brandDarkBlueContent: "white",
    brandDarkBlueContentAlt: "gray:50",
    brandLightBlue: "brand:lightBlue",
    brandGolden: "brand:golden",
    brandGoldenContent: "yellow:950",
    brandGoldenContentAlt: "yellow:800",
    brandGreen: "brand:green",
    brandGreenContent: "green:950",
    brandGreenContentAlt: "green:800",

    riskGradient1: "green:400",
    riskGradient2: "#B8E549",
    riskGradient3: "yellow:400",
    riskGradient4: "#FFA12B",
    riskGradient5: "red:500",

    loadingGradient1: "blue:50",
    loadingGradient2: "blue:100",
    loadingGradientContent: "blue:400",

    // not used yet
    brandCyan: "brand:cyan",
    brandCoral: "brand:coral",
    brandBrown: "brand:brown",
  },
} as const;

export type ThemeDescriptor = {
  name: "light";
  colors: typeof lightTheme.colors;
};
export type ThemeColorName = keyof ThemeDescriptor["colors"];

export function themeColor(theme: ThemeDescriptor, name: ThemeColorName) {
  const themeColor = theme.colors[name];
  if (themeColor.startsWith("#")) {
    return themeColor;
  }
  if (themeColor in colors) {
    return colors[themeColor as keyof typeof colors];
  }
  throw new Error(`Color ${themeColor} not found in theme`);
}

const ThemeContext = createContext({
  theme: lightTheme,
  setTheme: (_: ThemeDescriptor) => {},
});

export function useTheme() {
  const { theme, setTheme } = useContext(ThemeContext);
  return {
    color: (name: ThemeColorName) => themeColor(theme, name),
    setTheme,
    theme,
  };
}

export function Theme({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<ThemeDescriptor>(lightTheme);
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}
