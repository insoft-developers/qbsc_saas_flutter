import 'package:flutter/material.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/alarm/alarm.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/kipas/kipas.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/lampu/lampu.dart';
import 'package:qbsc_saas/app/views/laporan/anggota/kandang/suhu/suhu.dart';

class KandangTabPage extends StatelessWidget {
  const KandangTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'Monitoring Kandang',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.green,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Suhu'),
              Tab(text: 'Kipas'),
              Tab(text: 'Alarm'),
              Tab(text: 'Lampu'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            KandangSuhu(),
            KandangKipas(),
            KandangAlarm(),
            KandangLampu(),
          ],
        ),
      ),
    );
  }
}
