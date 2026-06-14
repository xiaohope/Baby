import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/moment_record.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';
import '../widgets/image_helper.dart';
import 'photo_preview_screen.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  Future<void> _addMoment() async {
    final result = await showDialog<MomentResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _AddMomentDialog(),
    );
    if (result == null || (result.text.isEmpty && result.images.isEmpty)) return;

    // 转base64直接存数据库
    List<String> base64Images = [];
    if (result.images.isNotEmpty) {
      for (final path in result.images) {
        try {
          final bytes = await File(path).readAsBytes();
          base64Images.add(base64Encode(bytes));
        } catch (_) {}
      }
    }

    final ds = context.read<DataService>();
    await ds.addMoment(MomentRecord(
      date: DateTime.now(),
      text: result.text,
      imagePaths: base64Images.isNotEmpty ? base64Images : result.images,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 已发布'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _deleteMoment(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除'),
        content: const Text('删除后将无法恢复'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              context.read<DataService>().deleteMoment(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMoment(MomentRecord record) async {
    final result = await showDialog<MomentResult>(
      context: context,
      builder: (ctx) => _AddMomentDialog(
        initialText: record.text,
        initialImages: record.imagePaths,
        isEdit: true,
      ),
    );
    if (result == null) return;

    // 转base64直接存数据库
    List<String> base64Images = [];
    for (final path in result.images) {
      if (path.length > 500) {
        base64Images.add(path); // 已经是base64
      } else {
        try {
          final bytes = await File(path).readAsBytes();
          base64Images.add(base64Encode(bytes));
        } catch (_) {
          base64Images.add(path);
        }
      }
    }

    final ds = context.read<DataService>();
    ds.deleteMoment(record.id);
    ds.addMoment(MomentRecord(
      date: DateTime.now(),
      text: result.text,
      imagePaths: base64Images,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.watch<DataService>();
    final moments = ds.momentRecords;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('动态'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        color: isDark ? const Color(0xFF121212) : null,
        child: moments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('还没有动态', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('点击右下角按钮发布', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade300, fontSize: 14)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: moments.length,
                itemBuilder: (ctx, i) {
                  final r = moments[i];
                  return _buildMomentCard(r, i);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMoment,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMomentCard(MomentRecord r, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = '${r.date.month}月${r.date.day}日  ${r.date.hour.toString().padLeft(2, '0')}:${r.date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: isDark ? const Color(0xFF1E1E1E) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：头像 + 名字 + 时间
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('👶', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('宝宝', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : null)),
                        Text(timeStr, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  // 操作按钮
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _editMoment(r);
                      if (v == 'delete') _deleteMoment(r.id);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('编辑')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('删除', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
              // 文案
              if (r.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(r.text, style: TextStyle(fontSize: 15, height: 1.5, color: isDark ? Colors.white : null)),
              ],
              // 图片九宫格
              if (r.imagePaths.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImageGrid(r.imagePaths),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> paths) {
    final count = paths.length;
    // 1张 → 满宽；2-4张 → 2列；5-9张 → 3列
    final crossAxisCount = count == 1 ? 1 : (count <= 4 ? 2 : 3);
    final childAspectRatio = count == 1 ? 1.2 : 1.0;
    final imageSize = count == 1 ? null : ((MediaQuery.of(context).size.width - 64) / crossAxisCount);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: childAspectRatio,
      children: paths.map((path) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhotoPreviewScreen(images: paths, initialIndex: paths.indexOf(path)),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildImage(path, width: imageSize, height: imageSize),
          ),
        );
      }).toList(),
    );
  }
}

// ====== 发布/编辑对话框 ======
class MomentResult {
  final String text;
  final List<String> images;
  MomentResult(this.text, this.images);
}

class _AddMomentDialog extends StatefulWidget {
  final String initialText;
  final List<String> initialImages;
  final bool isEdit;

  const _AddMomentDialog({
    this.initialText = '',
    this.initialImages = const [],
    this.isEdit = false,
  });

  @override
  State<_AddMomentDialog> createState() => _AddMomentDialogState();
}

class _AddMomentDialogState extends State<_AddMomentDialog> {
  late final TextEditingController _controller;
  late List<String> _images;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _images = List.from(widget.initialImages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      setState(() => _images.add(xFile.path));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _showImageSource() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择图片来源', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                title: const Text('拍照'),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6C63FF)),
                title: const Text('从相册选择'),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.isEdit ? '编辑动态' : '发布动态'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '说点什么...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFD4C5B5)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 已选图片预览
            if (_images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: buildImage(_images[i], width: 80, height: 80),
                      ),
                      Positioned(
                        top: -4, right: -4,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // 添加图片按钮
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _showImageSource,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('添加图片'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            MomentResult(_controller.text.trim(), _images),
          ),
          child: Text(widget.isEdit ? '保存' : '发布'),
        ),
      ],
    );
  }
}
