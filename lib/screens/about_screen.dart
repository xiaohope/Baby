import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于 Baby'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : null,
        iconTheme: IconThemeData(color: isDark ? Colors.white : null),
      ),
      body: Container(
        decoration: isDark ? null : const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F0FF), Color(0xFFFFF5EE), Color(0xFFF0F8FF)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        color: isDark ? const Color(0xFF121212) : null,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Logo
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF8A80)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: Text('👶', style: TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 12),
                    const Text('Baby', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                    const SizedBox(height: 4),
                    Text('v4.1.1', style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 功能介绍
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.star, color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 8),
                      Text('功能介绍', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                    ]),
                    const SizedBox(height: 12),
                    _featureItem('🍼', '喂奶记录', '记录亲喂、瓶喂、奶粉，支持计时器和手动输入'),
                    _featureItem('🧷', '换尿布', '记录小便、大便，可选择大便颜色'),
                    _featureItem('😴', '睡眠记录', '计时器记录宝宝睡眠时长，评估睡眠质量'),
                    _featureItem('📏', '生长发育', '记录体重、身长、头围，自动生成成长曲线图'),
                    _featureItem('🥣', '辅食添加', '记录食物名称、分量、宝宝喜好'),
                    _featureItem('🌡', '体温记录', '记录体温，高于37.5℃自动标红提醒'),
                    _featureItem('💊', '用药/补充', '自定义营养补充和用药记录'),
                    _featureItem('🛁', '洗澡/尿尿/粑粑', '日常护理记录'),
                    _featureItem('📸', '动态', '发图文，像朋友圈一样记录宝宝精彩瞬间'),
                    _featureItem('🌟', '里程碑', '记录宝宝的第一次翻身、爬行、走路等'),
                    _featureItem('📊', '数据统计', '今日概况、7天趋势、间隔分析、每周汇总'),
                    _featureItem('☁️', '云端同步', '多设备数据互通，家庭共享'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 使用说明
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.help_outline, color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 8),
                      Text('使用说明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                    ]),
                    const SizedBox(height: 12),
                    _tipItem('1', '首页', '顶部显示宝宝信息和今日概况，中间有快捷记录按钮，底部是近期记录'),
                    _tipItem('2', '添加记录', '点击首页的快捷按钮，或进入对应的记录页面填写信息'),
                    _tipItem('3', '编辑记录', '在添加页面点击已添加的记录，可修改后重新保存'),
                    _tipItem('4', '历史查看', '底部的"历史"页面可按分类查看所有记录，支持日期筛选'),
                    _tipItem('5', '数据统计', '"统计"页面展示今日概况和7天趋势图'),
                    _tipItem('6', '主题切换', '在"我的"页面可以切换浅色/深色主题'),
                    _tipItem('7', '云端同步', '注册账号后，所有记录自动同步到服务器，家庭成员可共享数据'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 关于我们
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 20),
                      const SizedBox(width: 8),
                      Text('关于我们', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      'Baby 是一款专为家长设计的宝宝成长记录 App。'
                      '记录宝宝成长的每一个瞬间，从喂奶、换尿布到辅食、体温，'
                      '所有数据一目了然。支持多设备云端同步，家庭成员共同记录，'
                      '不错过宝宝的每一步成长。',
                      style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white70 : null),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('返回'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text(num, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
