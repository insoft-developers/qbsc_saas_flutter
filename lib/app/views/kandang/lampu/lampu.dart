import 'package:flutter/material.dart';

class Lampu extends StatefulWidget {
  final int id;
  final String name;
  final bool isOn;

  const Lampu({
    super.key,
    required this.id,
    required this.name,
    this.isOn = false,
  });

  @override
  State<Lampu> createState() => _LampuState();
}

class _LampuState extends State<Lampu> {
  late bool lampuOn;

  @override
  void initState() {
    super.initState();
    lampuOn = widget.isOn;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'LAMPU ${widget.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: screenWidth * 0.35,
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lampuOn ? Colors.amber.shade400 : Colors.grey.shade300,
                boxShadow: lampuOn
                    ? [
                        BoxShadow(
                          color: Colors.amberAccent.withOpacity(0.6),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                lampuOn
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
                color: lampuOn ? Colors.yellow.shade100 : Colors.grey.shade600,
                size: screenWidth * 0.22,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              lampuOn ? 'Lampu Menyala' : 'Lampu Mati',
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                fontWeight: FontWeight.w700,
                color: lampuOn ? Colors.amber.shade700 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            SwitchListTile(
              title: Text(
                'Status Lampu',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: lampuOn,
              activeColor: Colors.amber.shade600,
              inactiveThumbColor: Colors.grey.shade400,
              onChanged: (value) {
                setState(() {
                  lampuOn = value;
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Di sini nanti bisa simpan ke Hive / API
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        lampuOn
                            ? 'Lampu diaktifkan untuk ${widget.name}'
                            : 'Lampu dimatikan untuk ${widget.name}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text(
                  'Simpan Status',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
