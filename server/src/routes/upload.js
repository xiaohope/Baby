const express = require('express');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const auth = require('../middleware/auth');

const router = express.Router();

// 确保图片目录存在
const uploadDir = path.resolve(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 上传图片（base64）
router.post('/', auth, async (req, res) => {
  try {
    const { image } = req.body;
    if (!image) {
      return res.status(400).json({ error: '缺少图片数据' });
    }

    // 格式: data:image/jpeg;base64,/9j/...
    const matches = image.match(/^data:image\/(\w+);base64,(.+)$/);
    if (!matches) {
      return res.status(400).json({ error: '无效的图片格式' });
    }

    const ext = matches[1] === 'jpeg' ? 'jpg' : matches[1];
    const fileName = `${uuidv4()}.${ext}`;
    const filePath = path.join(uploadDir, fileName);

    fs.writeFileSync(filePath, matches[2], 'base64');

    res.json({ url: `/uploads/${fileName}` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '上传失败' });
  }
});

module.exports = router;
