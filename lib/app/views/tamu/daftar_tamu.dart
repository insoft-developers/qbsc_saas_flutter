import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';
import 'package:shimmer/shimmer.dart';

class DaftarTamu extends StatefulWidget {
  const DaftarTamu({super.key});

  @override
  State<DaftarTamu> createState() => _DaftarTamuState();
}

class _DaftarTamuState extends State<DaftarTamu> {
  final TamuController _tamu = Get.put(TamuController());

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  static const Color primaryColor = Color(0xFF3C3535);
  static const Color backgroundColor = Color(0xFFF5F6F8);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tamu.getListTamu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _tamu.getListTamu();
  }

  List<Map<String, dynamic>> get _filteredList {
    final query = _searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      return _tamu.tamuList.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return _tamu.tamuList.map((e) => Map<String, dynamic>.from(e)).where((
      item,
    ) {
      final nama = item['nama_tamu']?.toString().toLowerCase() ?? '';
      final tujuan = item['tujuan']?.toString().toLowerCase() ?? '';

      return nama.contains(query) || tujuan.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Tamu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola data kunjungan tamu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah Tamu',
            onPressed: () async {
              await Get.toNamed('/tamu/tambah');
              _tamu.getListTamu();
            },
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final list = _filteredList;

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: _refreshData,
          child: _buildBody(context, list, isTablet),
        );
      }),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Map<String, dynamic>> list,
    bool isTablet,
  ) {
    if (_tamu.isLoading.value && _tamu.tamuList.isEmpty) {
      return _buildLoading(isTablet);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 28 : 16,
              18,
              isTablet ? 28 : 16,
              0,
            ),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 14),
                _buildSearchField(),
              ],
            ),
          ),
        ),

        if (list.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 28 : 16,
              18,
              isTablet ? 28 : 16,
              30,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildItem(list[index], isTablet);
              }, childCount: list.length),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Tamu',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_tamu.tamuList.length} Orang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  'Tamu',
                  style: TextStyle(
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
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _searchQuery.value = value;
        },
        decoration: InputDecoration(
          hintText: 'Cari nama atau tujuan...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
          suffixIcon: Obx(
            () => _searchQuery.value.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchQuery.value = '';
                    },
                    icon: const Icon(Icons.close_rounded, size: 19),
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> daftarTamu, bool isTablet) {
    final nama = daftarTamu['nama_tamu']?.toString() ?? '-';
    final tujuan = daftarTamu['tujuan']?.toString() ?? '-';
    final tiba = daftarTamu['arrive_at']?.toString() ?? '-';
    final pulang = daftarTamu['leave_at']?.toString();
    final status = daftarTamu['is_status'];

    final initial = nama.trim().isNotEmpty
        ? nama.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () async {
            final result = await Get.toNamed(
              '/tamu/detail',
              arguments: daftarTamu,
            );

            if (result == true) {
              _tamu.getListTamu();
            }
          },

          child: Padding(
            padding: EdgeInsets.all(isTablet ? 19 : 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(initial, isTablet),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTablet ? 17 : 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF202124),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status: status, leaveAt: pulang),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tujuan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12.5,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tiba,
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 11.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initial, bool isTablet) {
    return Container(
      width: isTablet ? 58 : 50,
      height: isTablet ? 58 : 50,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: primaryColor.withOpacity(0.12), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: primaryColor,
            fontSize: isTablet ? 21 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required dynamic status,
    required String? leaveAt,
  }) {
    final sudahPulang =
        leaveAt != null && leaveAt.isNotEmpty && leaveAt != 'null';

    final label = sudahPulang ? 'Pulang' : 'Tiba';
    final color = sudahPulang ? Colors.grey : Colors.green;
    final icon = sudahPulang ? Icons.logout_rounded : Icons.login_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isTablet) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 28 : 16,
        18,
        isTablet ? 28 : 16,
        30,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: isTablet ? 100 : 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final searching = _searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 40,
                color: primaryColor.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              searching ? 'Tamu tidak ditemukan' : 'Belum Ada Data Tamu',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              searching
                  ? 'Coba gunakan nama atau tujuan yang berbeda.'
                  : 'Data tamu yang terdaftar akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
