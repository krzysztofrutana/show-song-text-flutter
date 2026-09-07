class TextScrollModeHelper {
  // Enable to restore the mode selectors and saved horizontal display mode.
  static const bool allowHorizontal = false;

  static String effectiveMode(String? savedMode) {
    return allowHorizontal ? (savedMode ?? 'vertical') : 'vertical';
  }
}
