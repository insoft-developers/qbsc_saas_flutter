import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/utils/patroli_schedule.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_anggota_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_foto_preview.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_model.dart';

class PatroliAnggotaDetail extends StatelessWidget {
  final PatroliModel data;

  const PatroliAnggotaDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final _patroli = Get.find<PatroliAnggotaController>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Detail Patroli',
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
                  _fotoSatpam(context, "${ApiProvider.imageUrl}/${data.foto}"),
                  const SizedBox(height: 12),
                  Text(
                    data.locationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                    title: 'Informasi Patroli',
                    children: [
                      _row('ID Patrolit', data.id.toString()),
                      _row('Tanggal', Fungsi.tanggalIndo(data.tanggal)),
                      _row('Jam Patroli', data.jam),
                      _row('Satpam', data.satpamName),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Patroli Schedule',
                    children: buildPatroliSchedule(data.jamAwal, data.jamAkhir)
                        .map((schedule) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  schedule,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _patroli.openGoogleMaps(
                        double.parse(data.latitude.toString()),
                        double.parse(data.longitude.toString()),
                      );
                    },
                    child: _card(
                      title: 'Lokasi',
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

                  _card(
                    title: 'Catatan',
                    children: [_row('Deskripsi', data.note ?? '-')],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Metadata',
                    children: [
                      _row('Dibuat', Fungsi.formatDateTime(data.createdAt)),
                      _row('Perusahaan', data.companyName),
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

  Widget _iconPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Foto Patroli',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _fotoSatpam(BuildContext context, String? imageUrl) {
    final bool hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatroliFotoPreview(imageUrl: imageUrl!),
                ),
              );
            }
          : null,
      child: Hero(
        tag: imageUrl ?? 'no-image',
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => _iconPlaceholder(),
                  )
                : _iconPlaceholder(),
          ),
        ),
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
