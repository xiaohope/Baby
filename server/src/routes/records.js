const express = require('express');
const pool = require('../config/db');
const auth = require('../middleware/auth');

const router = express.Router();

// 批量上传记录
router.post('/upload', auth, async (req, res) => {
  try {
    const { records } = req.body;
    if (!records || !Array.isArray(records)) {
      return res.status(400).json({ error: '无效的记录数据' });
    }

    let uploaded = 0, errors = 0;

    for (const r of records) {
      try {
        const table = r.table;
        const data = r.data;
        if (!table || !data || !data.id) continue;

        // 家庭隔离：只查自己家庭的记录
        const tableMap = {
          feeding: { name: 'feeding_records', timeField: 'time' },
          diaper: { name: 'diaper_records', timeField: 'time' },
          sleep: { name: 'sleep_records', timeField: 'start_time' },
          growth: { name: 'growth_records', timeField: 'date' },
          milestone: { name: 'milestone_records', timeField: 'date' },
          supplement: { name: 'supplement_records', timeField: 'date' },
          moment: { name: 'moment_records', timeField: 'date' },
          simple: { name: 'simple_records', timeField: 'time' },
          food: { name: 'food_records', timeField: 'time' },
          temperature: { name: 'temperature_records', timeField: 'time' },
        };

        const tableInfo = tableMap[table];
        if (!tableInfo) { errors++; continue; }

        // UPSERT: 有则更新，无则插入
        const fields = Object.keys(data).map(k => {
          const val = data[k];
          if (val === null || val === undefined) return null;
          if (typeof val === 'object' && !(val instanceof Date)) return JSON.stringify(val);
          return val;
        });

        // 构建 INSERT ... ON DUPLICATE KEY UPDATE
        const keys = Object.keys(data);
        const placeholders = keys.map(() => '?').join(',');
        const updates = keys.map(k => {
          const col = k;
          if (k === 'id') return null;
          return `${col} = VALUES(${col})`;
        }).filter(Boolean).join(',');

        const values = keys.map(k => {
          const val = data[k];
          if (val === null || val === undefined) return null;
          if (typeof val === 'object') return JSON.stringify(val);
          return val;
        });

        const sql = `INSERT INTO ${tableInfo.name} (${keys.join(',')}, user_id, family_id) 
                     VALUES (${placeholders}, ?, ?)
                     ON DUPLICATE KEY UPDATE ${updates}`;

        await pool.query(sql, [...values, req.userId, req.familyId]);
        uploaded++;
      } catch (e) {
        errors++;
      }
    }

    res.json({ uploaded, errors });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 获取家庭所有记录（全量同步）
router.get('/sync', auth, async (req, res) => {
  try {
    const since = req.query.since || '2000-01-01';

    const tables = [
      'feeding_records', 'diaper_records', 'sleep_records',
      'growth_records', 'milestone_records', 'supplement_records',
      'moment_records', 'simple_records', 'food_records', 'temperature_records',
    ];

    const result = {};

    for (const table of tables) {
      const [rows] = await pool.query(
        `SELECT * FROM ${table} WHERE family_id = ? AND created_at >= ?`,
        [req.familyId, since]);
      result[table] = rows;
    }

    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 删除记录
router.delete('/:table/:id', auth, async (req, res) => {
  try {
    const { table, id } = req.params;
    // 验证表名防止 SQL 注入
    const allowedTables = [
      'feeding_records', 'diaper_records', 'sleep_records',
      'growth_records', 'milestone_records', 'supplement_records',
      'moment_records', 'simple_records', 'food_records', 'temperature_records',
    ];
    if (!allowedTables.includes(table)) {
      return res.status(400).json({ error: '无效的表名' });
    }
    await pool.query(`DELETE FROM ${table} WHERE id = ? AND family_id = ?`, [id, req.familyId]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
