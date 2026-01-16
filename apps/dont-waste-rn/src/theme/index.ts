export { colors } from './colors';
export type { Colors } from './colors';

export { spacing, radius } from './spacing';
export type { Spacing, Radius } from './spacing';

export { fontSizes, fontWeights, lineHeights, letterSpacing, textStyles } from './typography';
export type { FontSizes, TextStyles } from './typography';

// Combined theme object for convenience
export const theme = {
  colors: require('./colors').colors,
  spacing: require('./spacing').spacing,
  radius: require('./spacing').radius,
  typography: {
    fontSizes: require('./typography').fontSizes,
    fontWeights: require('./typography').fontWeights,
    lineHeights: require('./typography').lineHeights,
    letterSpacing: require('./typography').letterSpacing,
    textStyles: require('./typography').textStyles,
  },
} as const;
