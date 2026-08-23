enum AppVisualTheme {
  none,
  cosmic,
  nature,
  ocean,
  sakura,
  cyberpunk,
}

extension AppVisualThemeExtension on AppVisualTheme {
  String get title {
    switch (this) {
      case AppVisualTheme.none:
        return 'Theme-less';

      case AppVisualTheme.cosmic:
        return 'Cosmic';

      case AppVisualTheme.nature:
        return 'Nature';

      case AppVisualTheme.ocean:
        return 'Ocean';

      case AppVisualTheme.sakura:
        return 'Sakura';

      case AppVisualTheme.cyberpunk:
        return 'Cyberpunk';
    }
  }

  String get description {
    switch (this) {
      case AppVisualTheme.none:
        return 'Clean RDiary without a visual world';

      case AppVisualTheme.cosmic:
        return 'Explore your diary among the stars';

      case AppVisualTheme.nature:
        return 'A peaceful natural world';

      case AppVisualTheme.ocean:
        return 'A calm underwater experience';

      case AppVisualTheme.sakura:
        return 'Soft cherry blossom atmosphere';

      case AppVisualTheme.cyberpunk:
        return 'A futuristic neon world';
    }
  }

  bool get isAvailable {
    return this == AppVisualTheme.none || this == AppVisualTheme.cosmic;
  }
}