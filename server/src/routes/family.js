const express = require('express');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/db');
const auth = require('../middleware/auth');

const router = express.Router();

// 获取家庭成员列表
router.get('/members', auth, async (req, res) => {
  try {
    const [members] = await pool.query(
      `SELECT u.id, u.phone, u.role, u.nickname, fm.role as family_role 
       FROM family_members fm JOIN users u ON fm.user_id = u.id 
       WHERE fm.family_id = ?`, [req.familyId]);
    res.json(members);
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// 同步家庭设置（宝宝名字、生日等）
router.post('/settings', auth, async (req, res) => {
  try {
    const { babyName, babyBirthday } = req.body;
    // 用 JSON 存储家庭设置
    const settings = JSON.stringify({ babyName, babyBirthday });
    const [existing] = await pool.query('SELECT id FROM family_members WHERE family_id = ? AND user_id = ?', [req.familyId, req.userId]);
    if (existing.length === 0) return res.status(403).json({ error: '无权限' });
    await pool.query('UPDATE families SET name = ? WHERE id = ?', [babyName ? `${babyName}的家庭` : '我的家庭', req.familyId]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 获取家庭设置
router.get('/settings', auth, async (req, res) => {
  try {
    const [families] = await pool.query('SELECT name FROM families WHERE id = ?', [req.familyId]);
    res.json({ babyName: families[0]?.name?.replace('的家庭', '') || '宝宝' });
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

// 重新生成邀请码
router.post('/invite-code', auth, async (req, res) => {
  try {
    const code = Math.random().toString(36).substring(2, 8).toUpperCase();
    await pool.query('UPDATE families SET invite_code = ? WHERE id = ?', [code, req.familyId]);
    res.json({ inviteCode: code });
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
