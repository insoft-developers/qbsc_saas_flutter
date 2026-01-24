import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/notif/notif_model.dart';

class NotifDetail extends StatelessWidget {
  final NotifModel data;

  const NotifDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasImage = data.image != null && data.image!.isNotEmpty;
    final imageUrl = hasImage ? "${ApiProvider.imageUrl}/${data.image!}" : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Detail Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= JUDUL =================
            Text(
              data.judul,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ================= META =================
            Text(
              "${data.pengirim} • ${data.waktu}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

            // ================= GAMBAR (CLICK TO ZOOM) =================
            if (hasImage)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ImagePreviewPage(imageUrl: imageUrl!),
                    ),
                  );
                },
                child: Hero(
                  tag: imageUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ================= PESAN =================
            Text(
              data.fullPesan,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= FULLSCREEN IMAGE =================
class _ImagePreviewPage extends StatelessWidget {
  final String imageUrl;

  const _ImagePreviewPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
