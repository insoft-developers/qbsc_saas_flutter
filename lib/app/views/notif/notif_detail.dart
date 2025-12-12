import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/notif/notif_model.dart';

class NotifDetail extends StatelessWidget {
  final NotifModel data;

  const NotifDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasImage = data.image != null && data.image!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              data.judul,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Pengirim & waktu
            Text(
              "${data.pengirim} • ${data.waktu}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            // Pesan
            Text(data.pesan, style: const TextStyle(fontSize: 16, height: 1.4)),

            const SizedBox(height: 20),

            // 🔥 Gambar Opsional (jika ada saja tampil)
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "${ApiProvider.imageUrl}/${data.image!}",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
