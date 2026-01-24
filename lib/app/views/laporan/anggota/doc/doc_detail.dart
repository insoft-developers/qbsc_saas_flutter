import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/utils/fungsi.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/doc/doc_controller.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/doc/doc_model.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/patroli/patroli_foto_preview.dart';

class DocDetail extends StatelessWidget {
  final DocModel data;

  const DocDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final _doc = Get.find<DocController>();

    final boxOptions = _parseDocBoxOption(data.docBoxOptionJson);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Detail Doc Keluar',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =========================
            // HEADER FOTO
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(color: Color(0xFF0F172A)),
              child: _buildFotoSection(context),
            ),

            // =========================
            // CONTENT
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    title: 'Informasi Catatan DOC',
                    children: [
                      _row('ID', data.id.toString()),
                      _row('Tanggal', Fungsi.tanggalIndo(data.tanggal)),
                      _row('Jam', data.jam),
                      _row('Satpam', data.satpamName),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'DOC',
                    children: [
                      _row('Ekspedisi', data.ekspedisiName),
                      _row('Total Box', '${data.jumlah} Box'),
                      _row('Total Ekor', '${data.totalEkor} Ekor'),
                      _row('Jenis Doc', data.jenis == 1 ? 'Male' : 'Female'),
                      _row('Tujuan', data.tujuan ?? '-'),
                      _row('No Polisi', data.noPolisi ?? '-'),
                      _row('Nama Supir', data.namaSupir),
                      _row('Nomor Segel', data.nomorSegel),
                    ],
                  ),

                  // =========================
                  // BOX OPTION
                  // =========================
                  if (boxOptions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _card(
                      title: 'Detail Box',
                      children: boxOptions.map((opt) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.inventory,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${opt['option_name']} • '
                                  '${opt['jumlah_box']} box × '
                                  '${opt['isi']} = '
                                  '${opt['total_ekor']} ekor',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),

                  _card(
                    title: 'Catatan',
                    children: [_row('Deskripsi', data.note ?? '-')],
                  ),

                  const SizedBox(height: 12),

                  _card(
                    title: 'Metadata',
                    children: [
                      _row(
                        'Tanggal Input',
                        Fungsi.formatDateTime(data.inputDate ?? ''),
                      ),
                      _row('Dibuat', Fungsi.formatDateTime(data.createdAt)),
                      _row('Perusahaan', data.comName),
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
  // FOTO SECTION
  // =========================

  Widget _buildFotoSection(BuildContext context) {
    final fotos = _parseFotoDynamic(data.foto);

    if (fotos.isEmpty) {
      return _fotoDoc(context, null);
    }

    if (fotos.length == 1) {
      return _fotoDoc(context, '${ApiProvider.imageUrl}/${fotos.first}');
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        itemCount: fotos.length,
        itemBuilder: (context, index) {
          final imageUrl = '${ApiProvider.imageUrl}/${fotos[index]}';

          return _fotoDoc(context, imageUrl);
        },
      ),
    );
  }

  Widget _fotoDoc(BuildContext context, String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatroliFotoPreview(imageUrl: imageUrl),
                ),
              );
            }
          : null,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => _iconPlaceholder(),
                  ),
                )
              : _iconPlaceholder(),
        ),
      ),
    );
  }

  Widget _iconPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Tidak ada foto',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // =========================
  // CARD & ROW
  // =========================

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

  // =========================
  // HELPER PARSER
  // =========================

  List<String> _parseFotoDynamic(dynamic foto) {
    if (foto == null) return [];

    if (foto is List) {
      return foto.map((e) => e.toString()).toList();
    }

    if (foto is String) {
      try {
        final decoded = jsonDecode(foto);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
        return foto.isNotEmpty ? [foto] : [];
      } catch (_) {
        return foto.isNotEmpty ? [foto] : [];
      }
    }

    return [];
  }

  List<Map<String, dynamic>> _parseDocBoxOption(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List list = jsonDecode(jsonStr);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
