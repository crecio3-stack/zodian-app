import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { StyleProp, StyleSheet, Text, TextProps, TextStyle } from 'react-native';

type FitTextProps = TextProps & {
  children: string;
  style?: StyleProp<TextStyle>;
  maxFontSize?: number;
  minFontSize?: number;
  maxLines?: number;
  step?: number; // decrement step when shrinking
};

export default function FitText({
  children,
  style,
  maxFontSize,
  minFontSize = 10,
  maxLines,
  step = 1,
  ...rest
}: FitTextProps) {
  const flatStyle = StyleSheet.flatten(style) || {};
  const baseFont = (flatStyle.fontSize as number) || maxFontSize || 16;
  const initialMax = maxFontSize || baseFont;
  const [fontSize, setFontSize] = useState<number>(initialMax);
  const [measuringKey, setMeasuringKey] = useState(0);

  // If incoming style fontSize changes (e.g., orientation change), reset
  useEffect(() => {
    setFontSize(initialMax);
    // bump key to re-measure
    setMeasuringKey((k) => k + 1);
     
  }, [initialMax]);

  const onTextLayout = useCallback(
    (e: any) => {
      if (!maxLines) return; // nothing to do
      const lines = e.nativeEvent?.lines || [];
      // If rendered lines exceed the allowed lines, shrink font
      if (lines.length > maxLines && fontSize > minFontSize) {
        const next = Math.max(minFontSize, fontSize - step);
        if (next === fontSize) return;
        setFontSize(next);
        // bump key to force re-layout
        setMeasuringKey((k) => k + 1);
      }
    },
    [fontSize, maxLines, minFontSize, step]
  );

  const textStyle: TextStyle = useMemo(() => ({
    ...flatStyle,
    fontSize,
  }), [flatStyle, fontSize]);

  return (
    // key ensures a fresh measurement when fontSize resets/changes
    // numberOfLines is set to maxLines so the layout engine gives lines info
    <Text
      {...rest}
      key={measuringKey}
      style={textStyle}
      onTextLayout={onTextLayout}
      numberOfLines={maxLines}
    >
      {children}
    </Text>
  );
}
