import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';

class SatpamSummarySlider extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SatpamSummarySlider({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _SatpamSummaryCard(item: data[index]);
      },
    );
  }
}

// ===================================================================
// CARD
// ===================================================================
class _SatpamSummaryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _SatpamSummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final photoUrl = item['foto'] != null && item['foto'].toString().isNotEmpty
        ? "${ApiProvider.rootUrl}${item['foto']}"
        : null;

    final terlambat = (item['terlambat'] ?? {}) as Map<String, dynamic>;
    final cepatPulang = (item['cepat_pulang'] ?? {}) as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF9FAFB)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/images/satpam_default.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'] ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['jabatan'] ?? '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ================= INFO VERTICAL =================
          _InfoTile(
            label: 'Hadir',
            value: '${item['hadir'] ?? 0}',
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Tepat Waktu',
            value: '${item['tepat_waktu'] ?? 0}',
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Terlambat',
            value: '${terlambat['jumlah'] ?? 0} (${terlambat['menit'] ?? 0}m)',
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Cepat Pulang',
            value:
                '${cepatPulang['jumlah'] ?? 0} (${cepatPulang['menit'] ?? 0}m)',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Total Patroli',
            value: '${item['total_patroli'] ?? 0}',
            color: Colors.indigo,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Patroli Salah',
            value: '${item['patroli_diluar_jadwal'] ?? 0}',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// INFO TILE (FULL WIDTH, VERTICAL)
// ===================================================================
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
