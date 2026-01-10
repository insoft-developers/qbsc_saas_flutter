List<String> buildPatroliSchedule(String? jamAwal, String? jamAkhir) {
  if (jamAwal == null || jamAkhir == null) return [];

  final awalList = jamAwal.split(',').map((e) => e.trim()).toList();
  final akhirList = jamAkhir.split(',').map((e) => e.trim()).toList();

  final List<String> result = [];

  for (int i = 0; i < awalList.length; i++) {
    final start = awalList[i];
    final end = i < akhirList.length ? akhirList[i] : '-';
    result.add('$start - $end');
  }

  return result;
}
