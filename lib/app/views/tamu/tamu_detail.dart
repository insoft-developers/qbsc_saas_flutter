import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';

class DetailTamu extends StatelessWidget {
  DetailTamu({super.key});

  final TamuController c = Get.find<TamuController>();

  static const Color primaryColor = Color(0xFF3C3535);

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    try {
      final date = DateTime.parse(value.replaceFirst(' ', 'T'));

      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments as Map<String, dynamic>;

    final id = data['id'];
    final nama = data['nama_tamu']?.toString() ?? '-';
    final jumlah = data['jumlah_tamu']?.toString() ?? '0';
    final tujuan = data['tujuan']?.toString() ?? '-';
    final whatsapp = data['whatsapp']?.toString() ?? '-';
    final catatan = data['catatan']?.toString() ?? '-';
    final foto = data['foto']?.toString();
    final status = data['is_status'];
    final arriveAt = data['arrive_at']?.toString();
    final leaveAt = data['leave_at']?.toString();

    final masihDiLokasi = status == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Tamu',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfile(
              nama: nama,
              jumlah: jumlah,
              foto: foto,
              status: status,
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Informasi Kunjungan',
              children: [
                _infoRow(Icons.location_on_outlined, 'Tujuan', tujuan),
                _infoRow(Icons.groups_outlined, 'Jumlah Tamu', '$jumlah orang'),
                _infoRow(Icons.phone_outlined, 'WhatsApp', whatsapp),
                _infoRow(
                  Icons.login_rounded,
                  'Waktu Masuk',
                  _formatDate(arriveAt),
                ),
                _infoRow(
                  Icons.logout_rounded,
                  'Waktu Pulang',
                  leaveAt == null ? 'Belum pulang' : _formatDate(leaveAt),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              title: 'Catatan',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    catatan,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (masihDiLokasi)
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: c.isLoading.value
                        ? null
                        : () async {
                            final berhasil = await c.updateStatusTamu(id);

                            if (berhasil && context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                    icon: c.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout_rounded, color: Colors.white),
                    label: Text(
                      c.isLoading.value ? 'Memproses...' : 'TAMU PULANG',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      disabledBackgroundColor: Colors.grey.shade400,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Tamu sudah pulang',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile({
    required String nama,
    required String jumlah,
    required String? foto,
    required dynamic status,
  }) {
    final masihDiLokasi = status == 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPhoto(foto),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$jumlah orang',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: masihDiLokasi
                            ? Colors.orangeAccent
                            : Colors.greenAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        masihDiLokasi ? 'Masih di lokasi' : 'Sudah pulang',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String? foto) {
    if (foto == null || foto.isEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.person_rounded,
          color: Colors.white70,
          size: 40,
        ),
      );
    }

    final url = '${ApiProvider.imageUrl}/$foto';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 78,
            height: 78,
            color: Colors.white12,
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white70,
              size: 40,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: primaryColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF303030),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPulang(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Apakah Anda yakin tamu ini sudah pulang?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await c.updateStatusTamu(id);

                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Sudah Pulang'),
            ),
          ],
        );
      },
    );
  }
}
