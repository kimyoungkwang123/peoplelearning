const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');


// 로그인 처리
router.post('/login', express.json(), async (req, res) => {
  const userEmail = req.body.userEmail;  
  const password = req.body.password;

  console.log(userEmail);
  console.log(password);
  
  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.query(
      "SELECT * FROM users WHERE userEmail = ?",
      [userEmail]
    );

    if (result.length > 0) {
      const user = result[0];

      // 비밀번호 검증
      let passwordMatch = false;
      if (user.password.startsWith('$2')) {
        passwordMatch = await bcrypt.compare(password, user.password);
      } else {
        passwordMatch = (password === user.password);
      }

      if (passwordMatch) {
        // 로그인 성공 시 JWT 생성
        const token = jwt.sign(
          {userEmail: user.userEmail, userName:user.userName},
          'login_key', // 비밀키 변경
          { expiresIn: '1h' }
        );

        return res.status(200).json({
          code: 200,
          message: '로그인 성공',
          token: token, // 토큰 전달
          userEmail: user.userEmail,
          userName: user.userName,
        });

       

        
      } else {
        return res.status(401).json({
          code: 401,
          message: '아이디나 비밀번호가 틀렸습니다.'
        });
      }
    } else {
      return res.status(401).json({
        code: 401,
        message: '아이디나 비밀번호가 틀렸습니다.'
      });
    }
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).send('Internal Server Error: ' + err.message);
  } finally {
    if (conn) conn.end();
  }
});

  
  
  //회원가입 처리
  router.post('/signup', express.json(), async (req, res) => {
    const userEmail = req.body.userEmail;
    const cellphone = req.body.cellphone;
    const password = req.body.password;
    const userName = req.body.userName;
  
    console.log(userEmail);
    console.log(cellphone);
    console.log(password);
    console.log(userName);
  
    let conn;
    try {
      // 데이터베이스 연결 객체 생성
      conn = await pool.getConnection();
  
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

      console.log(result);
      // 회원가입 성공
      res.status(200).json({
        code: 200,
        message: '회원가입 성공',
      });
    } catch (err) {
      console.error('Signup error:', err.message);
      // 회원가입 실패
      res.status(500).json({
        code: 500,
        message: 'Internal Server Error',
      });
    } 
    finally {
      if (conn) conn.end(); // 데이터베이스 연결 해제
    }
  });




  //메인페이지(인기강의)
  router.get('/', async (req, res) => {

    let conn = null;

    try {
        conn = await pool.getConnection();

        const query = `
        SELECT
        l.lectureID,
        l.Lecture_image_URL,
        l.price,
        l.lectureTitle,
        AVG(e.scope) AS average_scope,
        i.instructorName,
        c.categoryName,
        c.categoryID
      FROM
        Lectures l
      JOIN
        Enrollments e ON l.lectureID = e.lectureID
      JOIN
        instructor i ON l.InstructorID = i.InstructorID
      LEFT JOIN 
        category c ON l.category1 = c.categoryID OR l.category2 = c.categoryID
      GROUP BY
        l.lectureID
      ORDER BY
        average_scope DESC
      LIMIT
        10;
        `;

        const lecture_list = await conn.query(query);
        if(lecture_list.length > 0){

          return res.json(
            {
              code: 200,
              message: '인기 수강 조회 성공',
              lecture_list
            }
          );
        }else{
          return res.json(
              {
                code: 401,
                message: '오류',
              }
            )
          }
    } catch (err) {
        console.error('Error fetching shopping basket:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});


// 카테고리 목록 조회 엔드포인트
router.get('/categorynamelist', async (req, res) => {
  let conn;

  try {
      conn = await pool.getConnection();

      const query = `
          SELECT categoryID, categoryName
          FROM category;
      `;

      const rows = await conn.query(query);
      res.json(rows);
  } catch (error) {
      console.error('Error fetching category list:', error);
      res.status(500).json({ error: 'Internal Server Error' });
  } finally {
      if (conn) {
          conn.release(); // 연결 반환
      }
  }
});




//메인페이지 검색로직
router.get('/search', async (req, res) => {
    const lectureTitle = req.query.lectureTitle;
    const categoryID = req.query.categoryID;
    let conn;

    lectureTitle ? `%${lectureTitle}%` : null;
    categoryID !== '' ? categoryID : null;
    try {
        conn = await pool.getConnection();
        console.log(lectureTitle);
        console.log(categoryID);
        const rows = await conn.query(`
        SELECT
                l.lectureID,
                l.lectureTitle,
                l.Lecture_image_URL,
                l.price,
                c.categoryID,
                c.categoryName,
                i.InstructorName
            FROM
                Lectures l
            JOIN
                category c ON (l.category1 = c.categoryID OR l.category2 = c.categoryID)
            JOIN
                instructor i ON l.InstructorID = i.InstructorID
            WHERE
                (l.lectureTitle LIKE ?) AND (c.categoryID = ? OR ? IS NULL)
            ORDER BY
                l.lectureTitle ASC;
        `, [`%${lectureTitle}%`, categoryID, categoryID]);


        console.log(rows)

        if (rows.length > 0) {
            res.status(200).json({
                code: 200,
                message: '성공',
                lecture_list: rows
            });
        } else {
            res.status(401).json({
                code: 401,
                message: '실패'
            });
        }
    } catch (err) {
        console.error('Error searching lectures:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});



 
  module.exports = router;

