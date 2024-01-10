const express = require('express');
const mariadb = require('mariadb');

const app = express();
const port = 3010;

// MariaDB 연결 풀 설정
const pool = mariadb.createPool({
  host: '15.164.219.104',
  user: 'root',
  password: '1234',
  database: 'peoplelearning',
  port: 3306,
  connectionLimit: 10
});


// 루트 경로에 "안녕" 출력
app.get('/', (req, res) => {
  res.send('안녕');
});

app.get('/data', async (req, res) => {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query('SELECT userEmail FROM users');
    console.log('Fetched data:', rows);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error11', details: err.message });
  } finally {
    if (conn) {
      // 연결을 풀에 반환하는 부분
      conn.release();
    }
  }
});



// 로그인 처리
app.post('/login', express.json(), async (req, res) => {
  const { username, password } = req.body;

  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.query('SELECT * FROM users WHERE userEmail = ? AND password = ?', [userEmail, password]);

    if (result.length > 0) {
      res.status(200).send('Login successful!');
    } else {
      res.status(401).send('Invalid credentials');
    }
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).send('Internal Server Error');
  } finally {
    if (conn) conn.end();
  }
});


// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
