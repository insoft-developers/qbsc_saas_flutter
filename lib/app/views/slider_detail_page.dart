import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:qbsc_saas/app/data/api_provider.dart';

class SliderDetailPage extends StatelessWidget {
  final Map<String, dynamic> slider;

  const SliderDetailPage({
    super.key,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = slider['image'] ?? '';
    final String title = slider['title'] ?? '';
    final String subtitle = slider['subtitle'] ?? '';
    final String content = slider['content'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Detail Informasi',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // IMAGE
            // =========================
            AspectRatio(
              aspectRatio: 1740 / 904,
              child: Image.network(
                '${ApiProvider.imageUrl}/$imageUrl',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // =========================
            // CONTENT
            // =========================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SUBTITLE
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // GARIS
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONTENT CKEDITOR
                  if (content.isNotEmpty)
                    HtmlWidget(
                      content,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF334155),
                        height: 1.7,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}