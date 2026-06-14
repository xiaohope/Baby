import 'package:flutter/material.dart';
import '../widgets/image_helper.dart';
import 'photo_preview_screen.dart';

class MomentDetailScreen extends StatelessWidget {
  final String text;
  final List<String> imagePaths;
  final String timeStr;

  const MomentDetailScreen({
    super.key,
    required this.text,
    required this.imagePaths,
    required this.timeStr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态详情'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null : const LinearGradient(
                  colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : null,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(timeStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              // 文案
              if (text.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(text, style: const TextStyle(fontSize: 16, height: 1.6)),
                ),
                const SizedBox(height: 16),
              ],
              // 图片
              if (imagePaths.isNotEmpty) ...[
                const Text('图片', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildImageGrid(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final count = imagePaths.length;
    final crossAxisCount = count == 1 ? 1 : (count <= 4 ? 2 : 3);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: count == 1 ? 1.2 : 1.0,
      children: imagePaths.map((path) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhotoPreviewScreen(
                images: imagePaths,
                initialIndex: imagePaths.indexOf(path),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: buildImage(path),
          ),
        );
      }).toList(),
    );
  }
}
