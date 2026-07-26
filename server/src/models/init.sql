CREATE DATABASE IF NOT EXISTS baby_record DEFAULT CHARSET utf8mb4;
USE baby_record;

-- 用户�?CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  phone VARCHAR(20) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('爸爸','妈妈') NOT NULL,
  nickname VARCHAR(50),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 家庭�?CREATE TABLE IF NOT EXISTS families (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(50) NOT NULL DEFAULT '我的家庭',
  invite_code VARCHAR(10) NOT NULL UNIQUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 家庭成员关联�?CREATE TABLE IF NOT EXISTS family_members (
  id VARCHAR(36) PRIMARY KEY,
  family_id VARCHAR(36) NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  role VARCHAR(20) NOT NULL COMMENT '爸爸/妈妈/爷爷/奶奶�?,
  FOREIGN KEY (family_id) REFERENCES families(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE KEY uk_family_user (family_id, user_id)
);

-- 喂奶记录
CREATE TABLE IF NOT EXISTS feeding_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  time DATETIME NOT NULL,
  type INT NOT NULL,
  breast_minutes INT,
  bottle_ml INT,
  note TEXT,
  breast_side INT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 尿布记录
CREATE TABLE IF NOT EXISTS diaper_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  time DATETIME NOT NULL,
  type INT NOT NULL,
  poop_color VARCHAR(20),
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 睡眠记录
CREATE TABLE IF NOT EXISTS sleep_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME,
  quality INT,
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 箢�单记�?尿尿/粑粑/用药/喝水/洗澡)
CREATE TABLE IF NOT EXISTS simple_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  category VARCHAR(20) NOT NULL,
  time DATETIME NOT NULL,
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 辅食记录
CREATE TABLE IF NOT EXISTS food_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  name VARCHAR(100) NOT NULL,
  portion VARCHAR(20),
  feeling VARCHAR(50),
  time DATETIME NOT NULL,
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- ���̼�¼
CREATE TABLE IF NOT EXISTS milk_storage_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  type VARCHAR(20) NOT NULL,
  date_time DATETIME NOT NULL,
  amount_ml INT,
  brand VARCHAR(100),
  amount_g INT,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- ���ݼ�¼
CREATE TABLE IF NOT EXISTS tooth_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  tooth_index INT NOT NULL,
  found_date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 体温记录
CREATE TABLE IF NOT EXISTS temperature_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  temperature DECIMAL(4,1) NOT NULL,
  time DATETIME NOT NULL,
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 成长记录
CREATE TABLE IF NOT EXISTS growth_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  date DATE NOT NULL,
  weight_kg DECIMAL(5,2),
  height_cm DECIMAL(5,2),
  head_circumference_cm DECIMAL(5,2),
  note TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 里程碑记�?CREATE TABLE IF NOT EXISTS milestone_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  date DATE NOT NULL,
  title VARCHAR(100) NOT NULL,
  note TEXT,
  category VARCHAR(20) DEFAULT 'milestone',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 补充记录
CREATE TABLE IF NOT EXISTS supplement_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  date DATE NOT NULL,
  items JSON,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- 动��记�?CREATE TABLE IF NOT EXISTS moment_records (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  date DATETIME NOT NULL,
  text_content TEXT,
  images JSON,
  user_name VARCHAR(50) DEFAULT '����',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- �ֿ����
CREATE TABLE IF NOT EXISTS inventory_categories (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(10) DEFAULT 'box',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- �����Ʒ
CREATE TABLE IF NOT EXISTS inventory_items (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  category_id VARCHAR(36) NOT NULL,
  name VARCHAR(100) NOT NULL,
  total INT DEFAULT 0,
  remaining INT DEFAULT 0,
  unit VARCHAR(20) DEFAULT '��',
  threshold INT DEFAULT 1,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- ʹ�ü�¼
CREATE TABLE IF NOT EXISTS inventory_usage (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  item_id VARCHAR(36) NOT NULL,
  used_count INT NOT NULL,
  used_at DATETIME NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);

-- �����嵥
CREATE TABLE IF NOT EXISTS shopping_items (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  family_id VARCHAR(36) NOT NULL,
  item_id VARCHAR(36),
  item_name VARCHAR(100) NOT NULL,
  quantity INT DEFAULT 1,
  is_done BOOLEAN DEFAULT FALSE,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (family_id) REFERENCES families(id)
);
