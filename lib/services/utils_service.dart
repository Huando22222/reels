class UtilsService {
  static String formatTime(DateTime sentTime) {
    final now = DateTime.now();
    final difference = now.difference(sentTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h ago";
    } else {
      return "${difference.inDays} d ago";
    }
  }
}
