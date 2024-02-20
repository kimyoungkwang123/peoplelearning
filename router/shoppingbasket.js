const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();



// 수강바구니 보기
router.get('/mybasket', async (req, res) => {
    const userEmail = req.query.userEmail;

    if (!userEmail) {
        return res.status(400).json({ error: 'userEmail parameter is required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        const query = `
            SELECT
                sb.shopping_basketID,
                sb.userEmail,
                l.Lecture_image_URL,
                l.lectureTitle,
                l.price,
                i.instructorName
            FROM
                shopping_basket sb
            JOIN
                Lectures l ON sb.lectureID = l.lectureID
            JOIN
                instructor i ON l.InstructorID = i.InstructorID
            WHERE
                sb.userEmail = ?;
        `;

        const rows = await conn.query(query, [userEmail]);
        console.log(rows);
        res.json({
            code : "200",
            mybasket_list : rows
        });
    } catch (err) {
        console.error('Error fetching shopping basket:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});
// 수강바구니 추가
router.post('/basketadd', async (req, res) => {
    const {userEmail, lectureID } = req.body;

    if (!userEmail || !lectureID) {
        return res.status(400).json({ error: 'userEmail and lectureID are required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        // 사용자의 수강 바구니에 강의를 추가하는 쿼리
        const insertQuery = `
            INSERT INTO shopping_basket (userEmail, lectureID, shopping_basketDate)
            VALUES (?, ?, NOW());
        `;

        await conn.query(insertQuery, [userEmail, lectureID]);
        res.status(200).json({ success: true, message: '성공' });
    } catch (err) {
        console.error('Error adding lecture to shopping basket:', err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    } finally {
        if (conn) conn.end();
    }
});

// 장바구니에서 항목을 삭제하는 엔드포인트
router.post('/basketdelete', async (req, res) => {
    const { userEmail, shoppingBasketID } = req.body;

    if (!userEmail || !shoppingBasketID) {
        return res.status(400).json({ error: 'userEmail and shoppingBasketID are required' });
    }

    let conn = null;

    try {
        conn = await pool.getConnection();

        // 사용자의 장바구니에서 항목을 삭제하는 쿼리
        const deleteQuery = `
            DELETE FROM shopping_basket
            WHERE userEmail = ? AND shopping_basketID = ?;
        `;

        await conn.query(deleteQuery, [userEmail, shoppingBasketID]);
        res.status(200).json({ success: true, message: '성공' });
    } catch (err) {
        console.error('Error deleting item from basket:', err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    } finally {
        if (conn) conn.end();
    }
});



module.exports = router;
