String normalizeCardName(String input) {
  final s = input.trim().toLowerCase();
  return s.replaceAll(RegExp(r'\s+'), ' ');
}
