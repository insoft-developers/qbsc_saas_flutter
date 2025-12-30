class NotifModel {
  final int id;
  final String judul;
  final String pesan;
  final String fullPesan;
  final String? image;
  final String pengirim;
  final String waktu;

  NotifModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.fullPesan,
    this.image,
    required this.pengirim,
    required this.waktu,
  });

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json['id'],
      judul: json['judul'],
      pesan: json['pesan'],
      fullPesan: json['full_pesan'],
      image: json['image'] ?? '',
      pengirim: json['pengirim'].toString(),
      waktu: json['waktu'].toString(),
    );
  }
}
