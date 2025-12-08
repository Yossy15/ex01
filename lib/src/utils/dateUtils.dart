class ThaiDateUtils {
  static const List<String> thaiMonthAbbreviations = [
    '',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.'
  ];

  static String formatThaiDate(DateTime date) {
    final thaiMonthAbbreviation = thaiMonthAbbreviations[date.month];
    return '${date.day} $thaiMonthAbbreviation ${date.year-1957} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} น.';
  }
}