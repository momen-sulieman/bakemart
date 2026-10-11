extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  String toEnglishDigits() {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String output = this;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return output.replaceAll('٫', '.');
  }
}