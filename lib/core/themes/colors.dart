import 'package:flutter/material.dart';

enum ColorPaletteKind {
  foreground,
  background,
}

class ColorPalette {
  const ColorPalette(
    this.name,
    this.colors, [
    this.kind = ColorPaletteKind.foreground,
  ]);

  final String name;
  final Map<int, int> colors;
  final ColorPaletteKind kind;

  Color getColorFromBrightness(
    final Brightness brightness, [
    final int level = 0,
  ]) =>
      Color(
        colors[adjustColorThreshold(
          getThresholdFromBrightness(brightness),
          brightness == Brightness.dark ? -level : level,
        )]!,
      );

  MaterialColor get asMaterialColor => MaterialColor(
        v500,
        colors.map(
          (final int key, final int value) => MapEntry<int, Color>(
            getMaterialColorCodeFromThreshold(key),
            Color(value),
          ),
        ),
      );

  int get v0 => colors[0]!;
  Color get c0 => Color(v0);
  int get v100 => colors[100]!;
  Color get c100 => Color(v100);
  int get v200 => colors[200]!;
  Color get c200 => Color(v200);
  int get v300 => colors[300]!;
  Color get c300 => Color(v300);
  int get v400 => colors[400]!;
  Color get c400 => Color(v400);
  int get v500 => colors[500]!;
  Color get c500 => Color(v500);
  int get v600 => colors[600]!;
  Color get c600 => Color(v600);
  int get v700 => colors[700]!;
  Color get c700 => Color(v700);
  int get v800 => colors[800]!;
  Color get c800 => Color(v800);
  int get v900 => colors[900]!;
  Color get c900 => Color(v900);

  static int getMaterialColorCodeFromThreshold(final int threshold) {
    if (threshold == 0) return 50;
    return threshold;
  }

  static int adjustColorThreshold(final int threshold, final int level) {
    final int nThreshold = threshold + (level * 100);
    if (nThreshold < 0) return 0;
    if (nThreshold > 900) return 900;
    return nThreshold;
  }

  static const Map<Brightness, int> _brightnessThresholdMap = <Brightness, int>{
    Brightness.light: 0,
    Brightness.dark: 900,
  };
  static int getThresholdFromBrightness(final Brightness brightness) =>
      _brightnessThresholdMap[brightness]!;
}

abstract class ColorPalettes {
  static const List<ColorPalette> all = <ColorPalette>[
    slate,
    gray,
    zinc,
    neutral,
    stone,
    red,
    orange,
    amber,
    yellow,
    lime,
    green,
    emerald,
    teal,
    cyan,
    sky,
    blue,
    indigo,
    violet,
    purple,
    fuchsia,
    pink,
    rose,
  ];

  static final List<ColorPalette> foregroundColors = all
      .where((final ColorPalette x) => x.kind == ColorPaletteKind.foreground)
      .toList();

  static final List<ColorPalette> backgroundColors = all
      .where((final ColorPalette x) => x.kind == ColorPaletteKind.background)
      .toList();

  // Generated from https://tailwindcss.com/docs/customizing-colors#default-color-palette
  static const ColorPalette slate = ColorPalette(
    'Slate',
    <int, int>{
      0: 0xFFF8FAFC,
      100: 0xFFF1F5F9,
      200: 0xFFE2E8F0,
      300: 0xFFCBD5E1,
      400: 0xFF94A3B8,
      500: 0xFF64748B,
      600: 0xFF475569,
      700: 0xFF334155,
      800: 0xFF1E293B,
      900: 0xFF0F172A
    },
    ColorPaletteKind.background,
  );

  static const ColorPalette gray = ColorPalette(
    'Gray',
    <int, int>{
      0: 0xFFF9FAFB,
      100: 0xFFF3F4F6,
      200: 0xFFE5E7EB,
      300: 0xFFD1D5DB,
      400: 0xFF9CA3AF,
      500: 0xFF6B7280,
      600: 0xFF4B5563,
      700: 0xFF374151,
      800: 0xFF1F2937,
      900: 0xFF111827
    },
    ColorPaletteKind.background,
  );

  static const ColorPalette zinc = ColorPalette(
    'Zinc',
    <int, int>{
      0: 0xFFFAFAFA,
      100: 0xFFF4F4F5,
      200: 0xFFE4E4E7,
      300: 0xFFD4D4D8,
      400: 0xFFA1A1AA,
      500: 0xFF71717A,
      600: 0xFF52525B,
      700: 0xFF3F3F46,
      800: 0xFF27272A,
      900: 0xFF18181B
    },
    ColorPaletteKind.background,
  );

  static const ColorPalette neutral = ColorPalette(
    'Neutral',
    <int, int>{
      0: 0xFFFAFAFA,
      100: 0xFFF5F5F5,
      200: 0xFFE5E5E5,
      300: 0xFFD4D4D4,
      400: 0xFFA3A3A3,
      500: 0xFF737373,
      600: 0xFF525252,
      700: 0xFF404040,
      800: 0xFF262626,
      900: 0xFF171717
    },
    ColorPaletteKind.background,
  );

  static const ColorPalette stone = ColorPalette(
    'Stone',
    <int, int>{
      0: 0xFFFAFAF9,
      100: 0xFFF5F5F4,
      200: 0xFFE7E5E4,
      300: 0xFFD6D3D1,
      400: 0xFFA8A29E,
      500: 0xFF78716C,
      600: 0xFF57534E,
      700: 0xFF44403C,
      800: 0xFF292524,
      900: 0xFF1C1917
    },
    ColorPaletteKind.background,
  );

  static const ColorPalette red = ColorPalette('Red', <int, int>{
    0: 0xFFFEF2F2,
    100: 0xFFFEE2E2,
    200: 0xFFFECACA,
    300: 0xFFFCA5A5,
    400: 0xFFF87171,
    500: 0xFFEF4444,
    600: 0xFFDC2626,
    700: 0xFFB91C1C,
    800: 0xFF991B1B,
    900: 0xFF7F1D1D
  });

  static const ColorPalette orange = ColorPalette('Orange', <int, int>{
    0: 0xFFFFF7ED,
    100: 0xFFFFEDD5,
    200: 0xFFFED7AA,
    300: 0xFFFDBA74,
    400: 0xFFFB923C,
    500: 0xFFF97316,
    600: 0xFFEA580C,
    700: 0xFFC2410C,
    800: 0xFF9A3412,
    900: 0xFF7C2D12
  });

  static const ColorPalette amber = ColorPalette('Amber', <int, int>{
    0: 0xFFFFFBEB,
    100: 0xFFFEF3C7,
    200: 0xFFFDE68A,
    300: 0xFFFCD34D,
    400: 0xFFFBBF24,
    500: 0xFFF59E0B,
    600: 0xFFD97706,
    700: 0xFFB45309,
    800: 0xFF92400E,
    900: 0xFF78350F
  });

  static const ColorPalette yellow = ColorPalette('Yellow', <int, int>{
    0: 0xFFFEFCE8,
    100: 0xFFFEF9C3,
    200: 0xFFFEF08A,
    300: 0xFFFDE047,
    400: 0xFFFACC15,
    500: 0xFFEAB308,
    600: 0xFFCA8A04,
    700: 0xFFA16207,
    800: 0xFF854D0E,
    900: 0xFF713F12
  });

  static const ColorPalette lime = ColorPalette('Lime', <int, int>{
    0: 0xFFF7FEE7,
    100: 0xFFECFCCB,
    200: 0xFFD9F99D,
    300: 0xFFBEF264,
    400: 0xFFA3E635,
    500: 0xFF84CC16,
    600: 0xFF65A30D,
    700: 0xFF4D7C0F,
    800: 0xFF3F6212,
    900: 0xFF365314
  });

  static const ColorPalette green = ColorPalette('Green', <int, int>{
    0: 0xFFF0FDF4,
    100: 0xFFDCFCE7,
    200: 0xFFBBF7D0,
    300: 0xFF86EFAC,
    400: 0xFF4ADE80,
    500: 0xFF22C55E,
    600: 0xFF16A34A,
    700: 0xFF15803D,
    800: 0xFF166534,
    900: 0xFF14532D
  });

  static const ColorPalette emerald = ColorPalette('Emerald', <int, int>{
    0: 0xFFECFDF5,
    100: 0xFFD1FAE5,
    200: 0xFFA7F3D0,
    300: 0xFF6EE7B7,
    400: 0xFF34D399,
    500: 0xFF10B981,
    600: 0xFF059669,
    700: 0xFF047857,
    800: 0xFF065F46,
    900: 0xFF064E3B
  });

  static const ColorPalette teal = ColorPalette('Teal', <int, int>{
    0: 0xFFF0FDFA,
    100: 0xFFCCFBF1,
    200: 0xFF99F6E4,
    300: 0xFF5EEAD4,
    400: 0xFF2DD4BF,
    500: 0xFF14B8A6,
    600: 0xFF0D9488,
    700: 0xFF0F766E,
    800: 0xFF115E59,
    900: 0xFF134E4A
  });

  static const ColorPalette cyan = ColorPalette('Cyan', <int, int>{
    0: 0xFFECFEFF,
    100: 0xFFCFFAFE,
    200: 0xFFA5F3FC,
    300: 0xFF67E8F9,
    400: 0xFF22D3EE,
    500: 0xFF06B6D4,
    600: 0xFF0891B2,
    700: 0xFF0E7490,
    800: 0xFF155E75,
    900: 0xFF164E63
  });

  static const ColorPalette sky = ColorPalette('Sky', <int, int>{
    0: 0xFFF0F9FF,
    100: 0xFFE0F2FE,
    200: 0xFFBAE6FD,
    300: 0xFF7DD3FC,
    400: 0xFF38BDF8,
    500: 0xFF0EA5E9,
    600: 0xFF0284C7,
    700: 0xFF0369A1,
    800: 0xFF075985,
    900: 0xFF0C4A6E
  });

  static const ColorPalette blue = ColorPalette('Blue', <int, int>{
    0: 0xFFEFF6FF,
    100: 0xFFDBEAFE,
    200: 0xFFBFDBFE,
    300: 0xFF93C5FD,
    400: 0xFF60A5FA,
    500: 0xFF3B82F6,
    600: 0xFF2563EB,
    700: 0xFF1D4ED8,
    800: 0xFF1E40AF,
    900: 0xFF1E3A8A
  });

  static const ColorPalette indigo = ColorPalette('Indigo', <int, int>{
    0: 0xFFEEF2FF,
    100: 0xFFE0E7FF,
    200: 0xFFC7D2FE,
    300: 0xFFA5B4FC,
    400: 0xFF818CF8,
    500: 0xFF6366F1,
    600: 0xFF4F46E5,
    700: 0xFF4338CA,
    800: 0xFF3730A3,
    900: 0xFF312E81
  });

  static const ColorPalette violet = ColorPalette('Violet', <int, int>{
    0: 0xFFF5F3FF,
    100: 0xFFEDE9FE,
    200: 0xFFDDD6FE,
    300: 0xFFC4B5FD,
    400: 0xFFA78BFA,
    500: 0xFF8B5CF6,
    600: 0xFF7C3AED,
    700: 0xFF6D28D9,
    800: 0xFF5B21B6,
    900: 0xFF4C1D95
  });

  static const ColorPalette purple = ColorPalette('Purple', <int, int>{
    0: 0xFFFAF5FF,
    100: 0xFFF3E8FF,
    200: 0xFFE9D5FF,
    300: 0xFFD8B4FE,
    400: 0xFFC084FC,
    500: 0xFFA855F7,
    600: 0xFF9333EA,
    700: 0xFF7E22CE,
    800: 0xFF6B21A8,
    900: 0xFF581C87
  });

  static const ColorPalette fuchsia = ColorPalette('Fuchsia', <int, int>{
    0: 0xFFFDF4FF,
    100: 0xFFFAE8FF,
    200: 0xFFF5D0FE,
    300: 0xFFF0ABFC,
    400: 0xFFE879F9,
    500: 0xFFD946EF,
    600: 0xFFC026D3,
    700: 0xFFA21CAF,
    800: 0xFF86198F,
    900: 0xFF701A75
  });

  static const ColorPalette pink = ColorPalette('Pink', <int, int>{
    0: 0xFFFDF2F8,
    100: 0xFFFCE7F3,
    200: 0xFFFBCFE8,
    300: 0xFFF9A8D4,
    400: 0xFFF472B6,
    500: 0xFFEC4899,
    600: 0xFFDB2777,
    700: 0xFFBE185D,
    800: 0xFF9D174D,
    900: 0xFF831843
  });

  static const ColorPalette rose = ColorPalette('Rose', <int, int>{
    0: 0xFFFFF1F2,
    100: 0xFFFFE4E6,
    200: 0xFFFECDD3,
    300: 0xFFFDA4AF,
    400: 0xFFFB7185,
    500: 0xFFF43F5E,
    600: 0xFFE11D48,
    700: 0xFFBE123C,
    800: 0xFF9F1239,
    900: 0xFF881337
  });
}
