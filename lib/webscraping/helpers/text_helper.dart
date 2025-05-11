class TextHelper {
  static String normalizeTextWithoutPolishSpecialChar(String text) {
    text = text.replaceAll("ł", "l");
    text = text.replaceAll("Ł", "L");

    return text;
  }

  static String encodeForUri(String text) {
    text = text.replaceAll("&", "&amp;");
    text = text.replaceAll("'", "&#039;");

    return text;
  }

  static String decodeFromUri(String text) {
    text = text.replaceAll("&amp;", "&");
    text = text.replaceAll("&#039;", "'");

    return text;
  }

  static String deleteStartAndEndEmptyLines(String text) {
    text = text.replaceAll('\\n', '\n');
    List<String> textLines = text.split('\n');
    List<String> result = text.split('\n');

    for (var i = 0; i < textLines.length; i++) {
      var line = textLines[i];

      if (line.isEmpty) {
        result.remove(line);
      } else {
        break;
      }
    }

    for (var i = textLines.length - 1; i > 0; i--) {
      var line = textLines[i];

      if (line.isEmpty) {
        result.remove(line);
      } else {
        break;
      }
    }

    StringBuffer sb = StringBuffer();

    for (var i = 0; i < result.length; i++) {
      var line = result[i];

      if (i < result.length - 1) {
        sb.write('$line\n');
      } else {
        sb.write(line);
      }
    }

    return sb.toString();
  }

  static String deleteLines(
      String text, int linesCountToRemove, bool startFromBottom) {
    text = text.replaceAll('\\n', '\n');
    List<String> result = [];

    List<String> textLines = text.split('\n');

    if (startFromBottom) {
      result = textLines.take(textLines.length - linesCountToRemove).toList();
    } else {
      result = textLines.skip(linesCountToRemove).toList();
    }

    StringBuffer sb = StringBuffer();

    for (var line in result) {
      sb.write('$line\n');
    }

    return sb.toString();
  }
}
