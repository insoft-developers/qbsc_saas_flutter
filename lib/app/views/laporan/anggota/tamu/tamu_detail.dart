import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/app_prefs.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_foto_preview.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/tamu/tamu_model.dart';

class TamuDetail extends StatelessWidget {
  final TamuModel data;

  const TamuDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final _tamu = Get.find<TamuController>();
    final userId = int.parse(AppPrefs.getUserId() ?? '0');
    String statusTamu = '';
    if (data.isStatus == 1) {
      statusTamu = 'Appointment';
    } else if (data.isStatus == 2) {
      statusTamu = 'Datang';
    } else if (data.isStatus == 3) {
      statusTamu = 'Pulang';
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Detail Tamu', style: TextStyle(color: Colors.white)),
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
                  _fotoDoc(context, "${ApiProvider.imageUrl}/${data.foto}"),
                  const SizedBox(height: 12),
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
                    title: 'Informasi Tamu',
                    children: [
                      _row('ID', data.id.toString()),
                      _row(
                        'Tanggal',
                        "${Fungsi.tanggalIndo(data.createdAt)} - ${Fungsi.formatToTime(data.createdAt)}",
                      ),
                      _row('Nama Tamu', data.namaTamu),
                      _row('Jumlah Tamu', "${data.jumlahTamu} orang"),
                      _row('Tujuan', data.tujuan ?? ''),
                      _row('Whatsapp', data.whatsapp ?? ''),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Jam Tamu',
                    children: [
                      _row('Datang', data.arriveAt ?? ' - '),
                      _row('Pulang', data.leaveAt ?? ' - '),
                      // _row(
                      //   'Pulang',
                      //   data.leaveAt != null
                      //       ? Fungsi.formatDateTime(data.leaveAt ?? '')
                      //       : '',
                      // ),
                      _row('Status', statusTamu),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Metadata',
                    children: [
                      _row('Dibuat', Fungsi.formatDateTime(data.createdAt)),
                      _row('Perusahaan', data.comName),
                    ],
                  ),

                  const SizedBox(height: 24),

                  data.createdBy == userId && data.isStatus == 1
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Copy Qr Link'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              copyLink(
                                context,
                                "${ApiProvider.rootUrl}/copy_link_tamu/${data.uuid}",
                              );
                            },
                          ),
                        )
                      : const SizedBox(),

                  const SizedBox(height: 12),
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

  Widget _fotoDoc(BuildContext context, String? imageUrl) {
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
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

  void copyLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link QR berhasil disalin!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
