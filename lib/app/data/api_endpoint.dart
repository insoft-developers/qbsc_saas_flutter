class ApiEndpoint {
  // Auth
  static const String login = "/login";
  static const String register = "/auth/register";
  static const String verifyFace = '/verify_face';
  static const String absenActive = '/absen_active';
  static const String locationData = '/location_data';
  static const String getDataLocation = '/get_data_location';
  static const String updateLocationCoordinates =
      '/update_location_coordinates';

  static const String sendPatroliToServer = '/send_patroli_to_server';
  static const String getDataKandang = '/get_data_kandang';
  static const String getDataEkspedisi = '/get_data_ekspedisi';
  static const String syncSuhuKandang = '/sync_suhu_kandang';
  static const String syncKipasKandang = '/sync_kipas_kandang';
  static const String syncAlarmKandang = '/sync_alarm_kandang';
  static const String syncLampuKandang = '/sync_lampu_kandang';
  static const String syncDocReport = '/sync_doc_report';
  static const String getDataShift = '/get_data_shift';
  static const String laporanSituasi = '/laporan_situasi';
  static const String checkQrTamu = '/check_qr_tamu';
  static const String saveDataTamu = '/save_data_tamu';
  static const String tambahDataTamu = '/tambah_data_tamu';

  static const String getListTamu = '/get_list_tamu';
  static const String updateStatusTamu = '/update_status_tamu';
  static const String checkPaket = '/check_paket';
  static const String emergency = '/darurat';
  static const String getNotifList = '/get_notif_list';
  static const String getProfileData = '/get_profile_data';
  static const String updateSatpamProfile = '/update_satpam_profile';
  static const String changePassword = '/ubah_password_satpam';

  // User
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/update";

  // Quiz, Leaderboard, dst (sesuai project kamu)
  static const String leaderboard = "/quiz/leaderboard";
}
