import React from 'react';
import { StyleProp, StyleSheet, View, ViewStyle } from 'react-native';
import Svg, { Circle, G, Path } from 'react-native-svg';

type CornerProps = {
  rotation: number;
  style?: StyleProp<ViewStyle>;
  size?: number;
};

function Corner({ rotation, style, size = 30 }: CornerProps) {
  return (
    <View pointerEvents="none" style={style}>
      <Svg width={size} height={size} viewBox="0 0 40 40" fill="none" style={{ transform: [{ rotate: `${rotation}deg` }] }}>
        <G opacity={0.68}>
          <Path d="M6 30C18 30 30 18 30 6" stroke="rgba(236,198,112,0.72)" strokeWidth={1.5} />
          <Path d="M12 30C21 30 30 21 30 12" stroke="rgba(236,198,112,0.4)" strokeWidth={1.1} />
          <Path d="M18.2 11.5L20 6.8L21.8 11.5L26.5 13.3L21.8 15.1L20 19.8L18.2 15.1L13.5 13.3L18.2 11.5Z" fill="rgba(251,230,170,0.76)" />
          <Circle cx={30} cy={6} r={1.4} fill="rgba(251,230,170,0.8)" />
        </G>
      </Svg>
    </View>
  );
}

type PremiumCornersProps = {
  inset?: number;
  size?: number;
};

export function PremiumCorners({ inset = 8, size = 30 }: PremiumCornersProps) {
  return (
    <>
      <Corner rotation={0} size={size} style={[styles.corner, { top: inset, left: inset }]} />
      <Corner rotation={90} size={size} style={[styles.corner, { top: inset, right: inset }]} />
      <Corner rotation={180} size={size} style={[styles.corner, { bottom: inset, right: inset }]} />
      <Corner rotation={270} size={size} style={[styles.corner, { bottom: inset, left: inset }]} />
    </>
  );
}

export function PremiumGlyph({ style }: { style?: StyleProp<ViewStyle> }) {
  return (
    <View pointerEvents="none" style={style}>
      <Svg width={24} height={24} viewBox="0 0 28 28" fill="none">
        <Circle cx={14} cy={14} r={7.2} stroke="rgba(241,208,126,0.74)" strokeWidth={1.2} />
        <Path d="M14 4.8V23.2M4.8 14H23.2" stroke="rgba(241,208,126,0.44)" strokeWidth={1} />
        <Path d="M13 8.6L14 6L15 8.6L17.6 9.6L15 10.6L14 13.2L13 10.6L10.4 9.6L13 8.6Z" fill="rgba(251,230,170,0.88)" />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  corner: {
    position: 'absolute',
  },
});
