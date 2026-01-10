import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';
import 'package:shimmer/shimmer.dart';

class DaftarTamu extends StatefulWidget {
  const DaftarTamu({super.key});

  @override
  State<DaftarTamu> createState() => _DaftarTamuState();
}

class _DaftarTamuState extends State<DaftarTamu> {
  final TamuController _tamu = Get.put(TamuController());

  @override
  void initState() {
    super.initState();
    _tamu.getListTamu();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final cardPadding = isTablet ? 24.0 : 16.0;
    final fontSize = isTablet ? 18.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 53, 53),
        title: const Text(
          'Daftar Tamu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // warna back button
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () => _tamu.getListTamu(),
          child: _tamu.isLoading.value
              ? ListView.builder(
                  padding: EdgeInsets.all(cardPadding),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    // SHIMMER (tetap seperti punyamu)
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : _tamu.tamuList.isEmpty
              // ===== DATA KOSONG =====
              ? const Center(
                  child: Text(
                    'Belum ada data tamu',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              // ===== DATA ADA =====
              : ListView.builder(
                  padding: EdgeInsets.all(cardPadding),
                  itemCount: _tamu.tamuList.length,
                  itemBuilder: (context, index) {
                    final DaftarTamu = _tamu.tamuList[index];
                    // 🔽 KODE ITEM MILIKMU (TIDAK DIUBAH)
                    return _buildItem(DaftarTamu, fontSize, cardPadding);
                  },
                ),
        ),
      ),
    );
  }
}

Widget _buildItem(
  Map<String, dynamic> DaftarTamu,
  double fontSize,
  double cardPadding,
) {
  // isi sama seperti yang sudah kamu buat
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: InkWell(
      // ...
    ),
  );
}
