const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();
const bcrypt = require('bcrypt');


//내강의 전체
router.get('/mylecture', async (req, res) => {
    const userEmail = req.query.userEmail;
    const type = req.query.type;
    const sort = req.query.sort; 


    if (!userEmail || !type) {
        return res.status(400).json({ error: 'userEmail and type parameters are required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        let query = '';
        let params = [userEmail];
        console.log(userEmail);
        console.log(type);
        console.log(sort);

        if (type === '전체') {
            if(sort === '이름순'){
            query = `
                    SELECT
                        e.lectureID,
                        e.progress,
                        l.Lecture_image_URL,
                        l.lectureTitle
                    FROM
                        Enrollments e
                    JOIN
                        Lectures l ON e.lectureID = l.lectureID
                    WHERE
                        e.userEmail = ?
                    ORDER BY
                        l.lectureTitle  ASC;
                `;
            }else if(sort === '진행률 높은순'){
                query =`
                SELECT
                    e.lectureID,
                    e.progress,
                    l.Lecture_image_URL,
                    l.lectureTitle
                FROM
                    Enrollments e
                JOIN
                    Lectures l ON e.lectureID = l.lectureID
                WHERE
                    e.userEmail = ?
                    AND e.progress < 100
                ORDER BY
                    e.progress DESC;`;
            }else if(sort === '진행률 낮은순'){
                query =`
                SELECT
                    e.lectureID,
                    e.progress,
                    l.Lecture_image_URL,
                    l.lectureTitle
                FROM
                    Enrollments e
                JOIN
                    Lectures l ON e.lectureID = l.lectureID
                WHERE
                    e.userEmail = ?
                    AND e.progress < 100
                ORDER BY
                    e.progress ASC;`;
            }else {
                return res.status(400).json({ error: 'Invalid type parameter' });
            }
        }
        //진행중인 강의
        else if (type === '학습중') {
            if (sort === '이름순') {
                query = `
                    SELECT
                        e.lectureID,
                        e.progress,
                        l.Lecture_image_URL,
                        l.lectureTitle
                    FROM
                        Enrollments e
                    JOIN
                        Lectures l ON e.lectureID = l.lectureID
                    WHERE
                        e.userEmail = ?
                        AND e.progress < 100
                    ORDER BY
                        l.lectureTitle ASC;
                `;
            } else if (sort === '진행률 높은순') {
                query = `
                    SELECT
                        e.lectureID,
                        e.progress,
                        l.Lecture_image_URL,
                        l.lectureTitle
                    FROM
                        Enrollments e
                    JOIN
                        Lectures l ON e.lectureID = l.lectureID
                    WHERE
                        e.userEmail = ?
                        AND e.progress < 100
                    ORDER BY
                        e.progress DESC;
                `;
            } else if (sort === '진행률 낮은순') {
                query = `
                    SELECT
                        e.lectureID,
                        e.progress,
                        l.Lecture_image_URL,
                        l.lectureTitle
                    FROM
                        Enrollments e
                    JOIN
                        Lectures l ON e.lectureID = l.lectureID
                    WHERE
                        e.userEmail = ?
                        AND e.progress < 100
                    ORDER BY
                        e.progress ASC;
                `;
            } else {
                return res.status(400).json({ error: 'Invalid sort parameter' });
            }
        }
        //완강한 강의
        else if (type === '완강') {
            query = `
                SELECT
                    e.lectureID,
                    e.progress,
                    l.Lecture_image_URL,
                    l.lectureTitle
                FROM
                    Enrollments e
                JOIN
                    Lectures l ON e.lectureID = l.lectureID
                WHERE
                    e.userEmail = ?
                    AND e.progress = 100;
            `;
        }else {
            return res.status(400).json({ error: 'Invalid type parameter' });
        }

        const rows = await conn.query(query, params );
        console.log(rows);
        res.json({
            code : "200",
            lecture_list : rows
        });
    } catch (err) {
        console.error('Error fetching user lectures:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});

//구매내역
router.get('/purchase-history', async (req, res) => {
    const userEmail = req.query.userEmail;

    if (!userEmail) {
        return res.status(400).json({ error: 'userEmail parameter is required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        const query = `
            SELECT
                l.Lecture_image_URL,
                l.lectureTitle,
                l.price,
                p.Payment_Method,
                p.payment_Date
            FROM
                payment p
            JOIN
                Enrollments e ON p.EnrollmentID = e.EnrollmentID
            JOIN
                Lectures l ON e.lectureID = l.lectureID
            WHERE
                p.userEmail = ?;
        `;

        const rows = await conn.query(query, [userEmail]);
        console.log(userEmail);
        console.log(rows);
        res.json({
            code : "200",
            payment_list : rows
        });
    } catch (err) {
        console.error('Error fetching purchase history:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});

//작성한 게시글
router.get('/myboard', async (req, res) => {
    const userEmail = req.query.userEmail;

    if (!userEmail) {
        return res.status(400).json({ error: 'userEmail parameter is required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        const query = `
        SELECT
        boardID,
        boardCount,
        boardTime,
        boardText,
        boardLike,
        boardTitle,
        boardUnlike
      FROM
        board
      WHERE
        userEmail = ?
      ORDER BY
        boardTime DESC;;
        `;

        const rows = await conn.query(query, [userEmail]);
        console.log(userEmail);
        console.log(rows);
        res.json({
            code : "200",
            board_list : rows
        });
    } catch (err) {
        console.error('Error fetching myboard:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});
//내 정보 수정
router.post('/update-user', async (req, res) => {
    const { userEmail, userName, currentPassword, newPassword } = req.body;

    if (!userEmail || !userName || !currentPassword || !newPassword) {
        return res.status(400).json({ error: 'userEmail, userName, currentPassword, and newPassword are required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        // 현재 사용자의 비밀번호를 가져옴
        const user = await conn.query(
            "SELECT password FROM users WHERE userEmail = ?",
            [userEmail]
        );
        console.log(user);
        if (user.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const storedPassword = user[0].password;

        // 클라이언트가 전송한 현재 비밀번호와 데이터베이스에 저장된 비밀번호를 비교
        const isPasswordCorrect = await bcrypt.compare(currentPassword, storedPassword);
        if (!isPasswordCorrect) {
            return res.status(401).json({ error: 'Current password is incorrect' });
        }

        // 새로운 비밀번호를 해싱
        const hashedNewPassword = await bcrypt.hash(newPassword, 10);

        // 사용자 정보 업데이트
        const updateQuery = `
            UPDATE users
            SET
                userName = ?,
                password = ?
            WHERE
                userEmail = ?;
        `;
        const queryParams = [userName, hashedNewPassword, userEmail];
        const rows =await conn.query(updateQuery, queryParams);
        console.log(rows);
        res.json({
            code: "200",
            message: 'Successfully updated user information'
        });
    } catch (err) {
        console.error('Error updating user information:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});





//작성한 게시글
router.post('/written', async (req, res) => {
    const { userEmail, boardCount, boardTime, boardText, boardLike, boardTitle, boardUnlike } = req.body;

    if (!userEmail) {
        return res.status(400).json({ error: 'userEmail is required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        const query = `
        INSERT INTO board (userEmail, boardCount, boardTime, boardText, boardLike, boardTitle, boardUnlike)
        VALUES (?, 0, NOW(), ?, 0, ?, 0);
        `;

        const rows = await conn.query(query, [userEmail, boardText, boardTitle]);
        console.log(rows);
        res.status(200).json({
            code: "200",
            message: 'successfully',
            boardwritten_list: rows
        });
    } catch (err) {
        console.error('Error inserting board information:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});


//결제
router.post('/payment', (req, res) => {
    const userEmail = req.body.userEmail;
    const EnrollmentID = req.body.EnrollmentID;
    const cardType = req.body.cardType;
    const Payment_Method = req.body.Payment_Method;
    const installmentPeriod = req.body.installmentPeriod;

    
    const paymentDate = new Date();

    // installmentPeriod가 null이면 null로 처리하고, 아니면 숫자로 변환
    const installmentValue = installmentPeriod !== null ? parseInt(installmentPeriod, 10) : null;

    pool.getConnection((err, conn) => {
        if (err) {
            console.error(err);
            return res.status(500).send('Internal Server Error');
        }

        const sqlInsertPayment = `
            INSERT INTO payment (userEmail, EnrollmentID, cardType, Payment_Method, installmentPeriod, payment_Date)
            VALUES (?, ?, ?, ?, ?, ?);
        `;

        const valuesInsertPayment = [userEmail, EnrollmentID, cardType, Payment_Method, installmentValue, paymentDate];

        conn.query(sqlInsertPayment, valuesInsertPayment, (errInsertPayment, resultInsertPayment) => {
            // 연결 사용이 끝났으면 반드시 반환
            conn.release();

            if (errInsertPayment) {
                console.error(errInsertPayment);
                return res.status(500).send('Internal Server Error');
            }

            res.json({
                success: true,
                message: '결제 성공'
            });
        });
    });
});









  module.exports = router;
