const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();


//전체강의 타입에 따라 sql문이달라짐
router.get('/', async (req, res) => {
    const type = req.query.type;
    let conn = null;

    try {
        conn = await pool.getConnection();
        let query = '';
        if (type === '강의제목순') {
            query = `
        SELECT
            l.lectureID,
            l.price,
            l.Lecture_image_URL,
            l.lectureTitle,
            i.InstructorName,
            AVG(e.scope) AS average_scope,
            c.categoryID,
            e.isPurchased  
        FROM
            Lectures l
        JOIN
            Enrollments e ON l.lectureID = e.lectureID
        JOIN
            instructor i ON l.InstructorID = i.InstructorID
        JOIN
            category c ON l.category1 = c.categoryID OR l.category2 = c.categoryID
        GROUP BY
            l.lectureID
        ORDER BY
            l.lectureTitle ASC;

        `;
        } else if (type === '평균별점 높은순') {
            // 평균별점순
            query = `
            SELECT
                l.lectureID,
                l.Lecture_image_URL,
                l.price,
                l.lectureTitle,
                i.InstructorName,
                AVG(e.scope) AS average_scope,
                c.categoryID,
                e.isPurchased    
            FROM
                Lectures l
            JOIN
                instructor i ON l.InstructorID = i.InstructorID
            JOIN
                Enrollments e ON l.lectureID = e.lectureID
            LEFT JOIN
                category c ON l.category1 = c.categoryID OR l.category2 = c.categoryID
            GROUP BY
                e.lectureID
            ORDER BY
                average_scope DESC;
        `;
        } else if (type === '가격 높은순') {
            // 가격 높은순
            query = `
            SELECT 
                l.lectureID,
                l.price,
                l.Lecture_image_URL,
                l.lectureTitle,
                i.InstructorName,
                AVG(e.scope) AS average_scope,
                c.categoryID,
                e.isPurchased  
            FROM
                Lectures l
            JOIN
                instructor i ON l.InstructorID = i.InstructorID
            JOIN
                Enrollments e ON l.lectureID = e.lectureID
            LEFT JOIN
                category c ON l.category1 = c.categoryID OR l.category2 = c.categoryID
            GROUP BY
                l.lectureID    
            ORDER BY
                price DESC;
        `;
        } else {
            res.status(400).send('Invalid type parameter');
            return;
        }

        
        // console.log(await conn.query(query));
        const rows = await conn.query(query, [type] );
        console.log(rows);
        res.json({
            code : "200",
            lecture_list : rows
        });

    } catch (err) {
        console.error('Error fetching total lectures:', err);
        res.status(500).send('Internal Server Error');
    } finally {
        if (conn) conn.end();
    }
});


module.exports = router;