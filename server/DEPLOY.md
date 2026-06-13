# 1. 上传 server/ 到服务器

# 2. 安装依赖
cd /path/to/server
npm install

# 3. 配置数据库
mysql -u root -p < src/models/init.sql

# 4. 修改 .env 中的数据库密码
vim .env  # 修改 DB_PASS=your_password

# 5. 启动服务（建议用 pm2）
npm install -g pm2
pm2 start src/index.js --name baby-api
pm2 save
pm2 startup

# 6. 配置宝塔反向代理
# 宝塔面板 → 网站 → 添加站点 → 设置 → 反向代理
# 目标URL: http://127.0.0.1:3000
