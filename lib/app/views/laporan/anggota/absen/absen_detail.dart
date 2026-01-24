import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absen/absen_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/absen/absen_model.dart';

class AbsenDetail extends StatelessWidget {
  final AbsenModel data;

  const AbsenDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final _absensi = Get.find<AbsenLaporanController>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Detail Absensi',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =========================
            // HEADER FOTO SATPAM
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(color: Color(0xFF0F172A)),
              child: Column(
                children: [
                  _fotoSatpam("${ApiProvider.imageUrl}/${data.fotoSatpam}"),
                  const SizedBox(height: 12),
                  Text(
                    data.namaSatpam,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.status == 1 ? 'Masuk' : 'Pulang',
                    style: TextStyle(
                      fontSize: 13,
                      color: data.status == 1
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    title: 'Informasi Absensi',
                    children: [
                      _row('ID Absensi', data.id.toString()),
                      _row('Tanggal', Fungsi.tanggalIndo(data.tanggal)),
                      _row('Jam Masuk', Fungsi.formatToTime(data.jamMasuk)),
                      _row(
                        'Jam Pulang',
                        data.jamKeluar != null
                            ? Fungsi.formatToTime(data.jamKeluar!)
                            : '-',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Shift',
                    children: [
                      _row('Nama Shift', data.shiftName ?? '-'),
                      _row('Jam Masuk Shift', data.jamSettingMasuk ?? '-'),
                      _row('Jam Pulang Shift', data.jamSettingPulang ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _absensi.openGoogleMaps(
                        double.parse(data.latitude.toString()),
                        double.parse(data.longitude.toString()),
                      );
                    },
                    child: _card(
                      title: 'Lokasi Masuk',
                      children: [
                        _row('Latitude', data.latitude.toString()),
                        _row('Longitude', data.longitude.toString()),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Buka di Google Maps',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _absensi.openGoogleMaps(
                        double.parse(data.latitude2.toString()),
                        double.parse(data.longitude2.toString()),
                      );
                    },
                    child: _card(
                      title: 'Lokasi Pulang',
                      children: [
                        _row('Latitude', data.latitude2.toString()),
                        _row('Longitude', data.longitude2.toString()),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Buka di Google Maps',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _card(
                    title: 'Catatan',
                    children: [
                      _row('Deskripsi', data.description ?? '-'),
                      _row('Catatan Masuk', data.catatanMasuk ?? '-'),
                      _row('Catatan Pulang', data.catatanKeluar ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (data.fotoMasuk!.isNotEmpty)
                        _buildFoto(
                          "${ApiProvider.imageUrl}/${data.fotoMasuk}",
                          'Masuk',
                        ),

                      if (data.fotoMasuk!.isNotEmpty ||
                          data.fotoKeluar!.isNotEmpty)
                        const SizedBox(width: 12),

                      if (data.fotoKeluar!.isNotEmpty)
                        _buildFoto(
                          "${ApiProvider.imageUrl}/${data.fotoKeluar}",
                          'Pulang',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _card(
                    title: 'Metadata',
                    children: [
                      _row('Dibuat', Fungsi.formatDateTime(data.createdAt)),
                      _row('Perusahaan', data.namaPerusahaan),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // WIDGET
  // =========================

  Widget _fotoSatpam(String? imageUrl) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : null,
        child: imageUrl == null || imageUrl.isEmpty
            ? const Icon(Icons.person, size: 40, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFoto(String url, String label) {
  return Column(
    children: [
      ClipOval(
        child: Image.network(
          url,
          width: 106,
          height: 106,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 24),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}
