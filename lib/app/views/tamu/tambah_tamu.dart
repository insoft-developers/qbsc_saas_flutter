import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbsc_saas/app/views/tamu/tamu_controller.dart';

class TambahTamu extends StatelessWidget {
  const TambahTamu({super.key});

  static const Color primaryColor = Color(0xFF3C3535);
  static const Color backgroundColor = Color(0xFFF6F7F9);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TamuController());

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Data Tamu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Lengkapi informasi tamu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Laporan Tamu',
            onPressed: () {
              Get.toNamed('/laporan/tamu');
            },
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Form(
          key: c.formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoHeader(),

                const SizedBox(height: 18),

                _buildSectionCard(
                  title: 'Informasi Tamu',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      _inputField(
                        label: 'Nama Tamu',
                        hint: 'Masukkan nama tamu',
                        icon: Icons.person_outline_rounded,
                        onChanged: c.setNamaTamu,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama tamu wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _inputField(
                        label: 'Jumlah Tamu',
                        hint: 'Contoh: 2',
                        icon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: c.setJumlahTamu,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Jumlah tamu wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _inputField(
                        label: 'Tujuan',
                        hint: 'Tujuan kedatangan tamu',
                        icon: Icons.location_on_outlined,
                        onChanged: c.setTujuan,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Tujuan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _inputField(
                        label: 'No. WhatsApp',
                        hint: 'Contoh: 08123456789',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        onChanged: c.setWhatsapp,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'No. WhatsApp wajib diisi';
                          }
                          return null;
                        },
                      ),

                      _inputField(
                        label: 'Catatan',
                        hint: 'Tambahkan catatan jika diperlukan',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                        onChanged: c.setNote,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Catatan wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _buildSectionCard(
                  title: 'Foto Identitas',
                  icon: Icons.badge_outlined,
                  child: Obx(() => _buildPhotoSection(c)),
                ),

                const SizedBox(height: 22),

                Obx(() => _buildSaveButton(context, c)),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.toNamed('/laporan/tamu');
        },
        icon: const Icon(Icons.receipt_long_rounded),
        label: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrasi Tamu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Masukkan data tamu dengan lengkap dan benar.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: primaryColor, size: 21),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  Widget _buildPhotoSection(TamuController c) {
    final hasPhoto = c.foto.value != null;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: hasPhoto ? Colors.black : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasPhoto ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(c.foto.value!, fit: BoxFit.cover),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'Ambil ulang',
                            onPressed: c.pickFoto,
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: primaryColor,
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Belum ada foto identitas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Foto digunakan sebagai identitas tamu',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: c.pickFoto,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor.withOpacity(0.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: Icon(
              hasPhoto ? Icons.refresh_rounded : Icons.camera_alt_outlined,
              size: 20,
            ),
            label: Text(
              hasPhoto ? 'Ambil Ulang Foto' : 'Ambil Foto',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, TamuController c) {
    final loading = c.isLoading.value;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading
            ? null
            : () {
                FocusScope.of(context).unfocus();

                if (c.validateForm()) {
                  c.saveDataTamuManualInput();
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Masih ada data yang belum lengkap'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: loading ? 0 : 3,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: loading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white, size: 21),
                  SizedBox(width: 10),
                  Text(
                    'SIMPAN DATA TAMU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget _inputField({
  required String label,
  required String hint,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
}) {
  final isMultiline = maxLines > 1;

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      textInputAction: isMultiline
          ? TextInputAction.newline
          : TextInputAction.next,

      keyboardType: isMultiline ? TextInputType.multiline : keyboardType,

      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,

      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, size: 21, color: Colors.grey.shade700),

        filled: true,
        fillColor: const Color(0xFFF8F9FA),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: TambahTamu.primaryColor,
            width: 1.4,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    ),
  );
}
