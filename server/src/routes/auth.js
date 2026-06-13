const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const pool = require('../config/db');
const auth = require('../middleware/auth');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const router = express.Router();

// 注册
router.post('/register', async (req, res) => {
  try {
    const { phone, password, role, nickname, inviteCode } = req.body;
    if (!phone || !password || !role) {
      return res.status(400).json({ error: '手机号、密码和角色为必填' });
    }
    if (!['爸爸','妈妈'].includes(role)) {
      return res.status(400).json({ error: '角色只能是"爸爸"或"妈妈"' });
    }

    // 检查手机号是否已注册
    const [existing] = await pool.query('SELECT id FROM users WHERE phone = ?', [phone]);
    if (existing.length > 0) {
      return res.status(400).json({ error: '该手机号已注册' });
    }

    const userId = uuidv4();
    const hashedPwd = await bcrypt.hash(password, 10);

    // 如果有关联的家庭
    let familyId, inviteCodeGen;

    if (inviteCode) {
      // 用邀请码加入家庭
      const [family] = await pool.query('SELECT id FROM families WHERE invite_code = ?', [inviteCode]);
      if (family.length === 0) {
        return res.status(400).json({ error: '邀请码无效' });
      }
      familyId = family[0].id;
    } else {
      // 创建新家庭
      familyId = uuidv4();
      inviteCodeGen = Math.random().toString(36).substring(2, 8).toUpperCase();
      await pool.query('INSERT INTO families (id, name, invite_code) VALUES (?, ?, ?)',
        [familyId, `${nickname || phone}的家庭`, inviteCodeGen]);
    }

    // 创建用户
    await pool.query(
      'INSERT INTO users (id, phone, password, role, nickname) VALUES (?, ?, ?, ?, ?)',
      [userId, phone, hashedPwd, role, nickname || null]);

    // 加入家庭
    await pool.query(
      'INSERT INTO family_members (id, family_id, user_id, role) VALUES (?, ?, ?, ?)',
      [uuidv4(), familyId, userId, role]);

    // 生成 token
    const token = jwt.sign({ userId, familyId }, process.env.JWT_SECRET, { expiresIn: '30d' });

    res.json({
      token,
      user: { id: userId, phone, role, nickname: nickname || '' },
      family: { id: familyId, inviteCode: inviteCodeGen || inviteCode },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 登录
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    if (!phone || !password) {
      return res.status(400).json({ error: '请输入手机号和密码' });
    }

    const [users] = await pool.query('SELECT * FROM users WHERE phone = ?', [phone]);
    if (users.length === 0) {
      return res.status(400).json({ error: '手机号未注册' });
    }

    const user = users[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(400).json({ error: '密码错误' });
    }

    // 获取家庭信息
    const [members] = await pool.query(
      'SELECT family_id FROM family_members WHERE user_id = ?', [user.id]);
    if (members.length === 0) {
      return res.status(400).json({ error: '未加入任何家庭' });
    }
    const familyId = members[0].family_id;

    const [families] = await pool.query('SELECT * FROM families WHERE id = ?', [familyId]);

    const token = jwt.sign({ userId: user.id, familyId }, process.env.JWT_SECRET, { expiresIn: '30d' });

    res.json({
      token,
      user: { id: user.id, phone: user.phone, role: user.role, nickname: user.nickname || '' },
      family: { id: familyId, name: families[0].name, inviteCode: families[0].invite_code },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 获取用户信息
router.get('/me', auth, async (req, res) => {
  try {
    const [users] = await pool.query('SELECT id, phone, role, nickname FROM users WHERE id = ?', [req.userId]);
    const [families] = await pool.query('SELECT * FROM families WHERE id = ?', [req.familyId]);
    const [members] = await pool.query(
      `SELECT u.id, u.phone, u.role, u.nickname, fm.role as family_role 
       FROM family_members fm JOIN users u ON fm.user_id = u.id 
       WHERE fm.family_id = ?`, [req.familyId]);

    res.json({
      user: users[0],
      family: families[0],
      members,
    });
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
