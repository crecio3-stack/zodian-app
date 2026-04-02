import React from 'react';
import { StyleSheet, View } from 'react-native';
import Svg, { Circle, Ellipse, Path } from 'react-native-svg';

type Props = {
  westernSign: string;
  chineseSign: string;
};

export default function ZodiacPairEmblem({ westernSign, chineseSign }: Props) {
  if (westernSign !== 'Aries' || chineseSign !== 'Horse') {
    return null;
  }

  return (
    <View pointerEvents="none" style={styles.wrap}>
      <Svg width={128} height={128} viewBox="0 0 128 128" fill="none">
        <Circle cx={64} cy={64} r={48} stroke="rgba(227,194,110,0.92)" strokeWidth={2.8} />
        <Ellipse cx={64} cy={64} rx={42} ry={42} stroke="rgba(227,194,110,0.22)" strokeWidth={1.2} />

        <Path
          d="M37 79C43 69 50 59 58 49C63 42 69 37 76 34C82 31 88 31 93 35C96 38 98 42 99 47"
          stroke="rgba(236,205,126,0.92)"
          strokeWidth={3.2}
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <Path
          d="M51 74C59 78 68 80 78 80C86 80 92 78 97 74"
          stroke="rgba(236,205,126,0.8)"
          strokeWidth={2.2}
          strokeLinecap="round"
        />
        <Path
          d="M76 34C74 28 75 23 79 19C83 15 88 14 93 17"
          stroke="rgba(236,205,126,0.92)"
          strokeWidth={3.2}
          strokeLinecap="round"
        />
        <Path
          d="M81 35C83 29 88 25 94 25C100 25 105 29 107 35"
          stroke="rgba(236,205,126,0.92)"
          strokeWidth={3.2}
          strokeLinecap="round"
        />

        <Path
          d="M48 41C43 35 37 31 30 29"
          stroke="rgba(227,194,110,0.82)"
          strokeWidth={2.8}
          strokeLinecap="round"
        />
        <Path
          d="M48 41C44 40 40 40 36 42C31 44 28 48 27 53"
          stroke="rgba(227,194,110,0.82)"
          strokeWidth={2.8} 
          strokeLinecap="round"
        />
        <Path
          d="M80 41C85 35 91 31 98 29"
          stroke="rgba(227,194,110,0.82)"
          strokeWidth={2.8}
          strokeLinecap="round"
        />
        <Path
          d="M80 41C84 40 88 40 92 42C97 44 100 48 101 53"
          stroke="rgba(227,194,110,0.82)"
          strokeWidth={2.8}
          strokeLinecap="round"
        />

        <Circle cx={88} cy={43} r={2.4} fill="rgba(250,227,164,0.95)" />
        <Path
          d="M25 87H103"
          stroke="rgba(227,194,110,0.3)"
          strokeWidth={1.4}
          strokeLinecap="round"
        />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 14,
  },
});