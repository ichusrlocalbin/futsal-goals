class Utils {
  static String dateFormatString(String dateStr) {
    return "${dateStr.substring(0, 4)}/${dateStr.substring(4, 6)}/${dateStr.substring(6, 8)}";
  }
}
