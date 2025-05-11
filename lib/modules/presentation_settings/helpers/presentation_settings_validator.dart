mixin PresentationSettingsValidator {
  String? validateFontSize(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wielkość czcionki musi być większa od 5';
    }
    if (int.tryParse(value) == null) {
      return 'Wprowadzona wartość nie jest liczbą';
    }

    if (int.parse(value) < 5) return 'Wielkość czcionki musi być większa od 5';
    return null;
  }
}
