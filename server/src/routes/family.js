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
