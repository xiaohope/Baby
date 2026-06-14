const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const familyRoutes = require('./routes/family');
const recordsRoutes = require('./routes/records');
const uploadRoutes = require('./routes/upload');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// 路由
app.use('/api/auth', authRoutes);
app.use('/api/family', familyRoutes);
app.use('/api/records', recordsRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/uploads', express.static('uploads'));

// 版本检查
app.get('/api/version', (req, res) => {
  res.json({
    version: '4.1.0',
    apkUrl: '/downloads/baby.apk',
    updateUrl: 'https://github.com/xiaohope/Baby/releases/latest',
    desc: '新增: 数据实时同步、图片base64存储、bug修复',
  });
});

// 静态文件（APK下载）
app.use('/downloads', express.static('downloads'));

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Baby API Server running on port ${PORT}`);
});
