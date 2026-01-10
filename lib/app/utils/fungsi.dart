class Fungsi {
  static String formatToTime(String dateTimeString) {
    try {
      // Parse string ke DateTime
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Ambil jam, menit, detik
      String formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
      return formattedTime;
    } catch (e) {
      return "-"; // kalau format salah
    }
  }

  static String tanggalIndo(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      const bulan = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return "${date.day} ${bulan[date.month - 1]} ${date.year}";
    } catch (e) {
      return "-";
    }
  }

  static String formatDateTime(String dateTime) {
    final DateTime dt = DateTime.parse(dateTime).toLocal();

    String twoDigit(int n) => n.toString().padLeft(2, '0');

    return '${twoDigit(dt.day)}-${twoDigit(dt.month)}-${dt.year} '
        '${twoDigit(dt.hour)}:${twoDigit(dt.minute)}';
  }
}
