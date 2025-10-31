import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AbsensiCard extends StatelessWidget {
  final String status;
  final String jamMasuk;
  final String jamKeluar;
  final String tanggal;

  const AbsensiCard({
    super.key,
    required this.status,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.tanggal,
  });

  LinearGradient getStatusGradient(String status) {
    switch (status) {
      case 'masuk':
        return LinearGradient(
          colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case 'keluar':
        return LinearGradient(
          colors: [Colors.orangeAccent.shade100, Colors.orangeAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case 'kosong':
        return LinearGradient(
          colors: [Colors.redAccent.shade100, Colors.redAccent.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      default:
        return LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String isMasuk = '';
    if (status.toLowerCase() == 'masuk') {
      isMasuk = 'masuk';
    } else if (status.toLowerCase() == 'pulang') {
      isMasuk = 'pulang';
    } else {
      isMasuk = 'kosong';
    }

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: getStatusGradient(isMasuk),

        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status Absensi",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isMasuk == 'masuk' ? Icons.check_circle : Icons.access_time,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isMasuk == 'kosong' ? 'Belum Absen' : isMasuk,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 28, thickness: 0.7),
          _buildInfoRow("Tanggal", tanggal),
          const SizedBox(height: 8),
          _buildInfoRow("Jam Masuk", jamMasuk),
          const SizedBox(height: 8),
          _buildInfoRow("Jam Keluar", jamKeluar),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
