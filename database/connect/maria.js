// const express = require('express');
// const session = require('express-session');
// const mariadb = require('mariadb');
// const bcrypt = require('bcrypt');
// const app = express();

// // URL 인코딩된 데이터를 파싱하기 위한 미들웨어 등록
// app.use(express.urlencoded({ extended: true }));

// // 세션을 사용하기 위한 미들웨어 등록
// app.use(session({ secret: 'your_secret_key', resave: false, saveUninitialized: true }));

// // MariaDB 연결 풀 설정
// const pool = mariadb.createPool({
//   host: 'localhost:3306',
//   user: 'root',
//   password: 'qwer1234',
//   database: 'test',
//   connectionLimit: 5
// });

// // 라우트 및 기본 페이지 설정

// // 로그인 폼 렌더링
// app.get('/login', (req, res) => {
//   res.sendFile(__dirname + '/views/login.html');
// });

// // 로그인 처리
// app.post('/login', async (req, res) => {
//   const { username, password } = req.body;

//   const conn = await pool.getConnection();
//   try {
//     const result = await conn.query('SELECT * FROM users WHERE username = ?', [username]);
//     if (result.length > 0) {
//       const match = await bcrypt.compare(password, result[0].password);
//       if (match) {
//         req.session.user = username;
//         res.redirect('/dashboard');
//       } else {
//         res.send('Incorrect password');
//       }
//     } else {
//       res.send('User not found');
//     }
//   } catch (error) {
//     console.error(error);
//     res.status(500).send('Internal Server Error');
//   } finally {
//     if (conn) conn.end();
//   }
// });

// // 대시보드 렌더링
// app.get('/dashboard', (req, res) => {
//   if (req.session.user) {
//     res.send(`Welcome, ${req.session.user}!`);
//   } else {
//     res.redirect('/login');
//   }
// });

// // 로그아웃
// app.get('/logout', (req, res) => {
//   req.session.destroy(() => {
//     res.redirect('/');
//   });
// });

// // 서버 시작
// app.listen(3000, () => {
//   console.log('Server is running on port 3000');
// });
