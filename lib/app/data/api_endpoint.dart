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
  static const String syncSuhuKandang = '/sync_suhu_kandang';
  static const String syncKipasKandang = '/sync_kipas_kandang';
  static const String syncAlarmKandang = '/sync_alarm_kandang';
  static const String syncLampuKandang = '/sync_lampu_kandang';

  // User
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/update";

  // Quiz, Leaderboard, dst (sesuai project kamu)
  static const String leaderboard = "/quiz/leaderboard";
}
