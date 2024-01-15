const express = require('express');
const mariadb = require('mariadb');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');

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

app.get('/data', async (req, res) => {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query('SELECT userEmail FROM users');
    console.log('Fetched data:', rows);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error : 'Internal Server Error11', details : err.message });
  } finally {
    if (conn) {
      // 연결을 풀에 반환하는 부분
      conn.release();
    }
  }
});


// 로그인 처리
app.post('/login', express.json(), async (req, res) => {
  const { userEmail, password } = req.body;

  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.query(
      "SELECT * FROM users WHERE userEmail = ? AND password = ?",
      [userEmail, password]);

    if (result.length > 0) {
      res.status(200).send('로그인 성공');
    } else {
      res.status(401).send('아이디나 비밀번호가 틀렸습니다.');
    }
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).send('Internal Server Error');
  } finally {
    if (conn) conn.end();
  }
});

//회원가입 처리

app.post('/signup', express.json(), async (req, res) => {
  const { userEmail, cellphone, password, userName } = req.body;

  try {
    // 사용자 이메일 중복 확인
    const existingUser = await conn.query(
      "SELECT * FROM `users` WHERE `userEmail` = ?",
      [userEmail]
    );

    if (existingUser.length > 0) {
      // 이미 존재하는 이메일인 경우 회원가입 실패
      res.status(401).json({
        code: 401,
        message: '이미 존재하는 이메일입니다.',
      });
      return;
    }

    // 비밀번호 해싱
    const hashedPassword = await bcrypt.hash(password, 10);

    // 사용자 추가
    const result = await conn.query(
      "INSERT INTO `users` (`userEmail`, `cellphone`, `password`, `userName`, `userType`) VALUES (?, ?, ?, ?, 'student')",
      [userEmail, cellphone, hashedPassword, userName]
    );

    // 회원가입 성공
    res.status(200).json({
      code: 200,
      message: '회원가입 성공',
    });
  } catch (err) {
    console.error('Signup error:', err);
    // 회원가입 실패
    res.status(500).json({
      code: 500,
      message: 'Internal Server Error',
    });
  }
});




// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
