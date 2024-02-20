const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();


router.get('/', async (req, res) => {
    try {
        const lectureId = req.query.lectureID;
        const userEmail = req.query.userEmail;
        if (!userEmail) {
            // 강의자료를 비활성화하도록 기본값 설정
            console.log(lectureId);
            const lectureInfoResult = await pool.query(`
            SELECT 
    lm.lecture_materialsType,
    lm.lecture_materialsURL,
    l.lectureTitle,
    l.lectureText,
    l.Lecture_materialsID,
    l.Lecture_image_URL,
    l.price,
    AVG(e.scope) AS average_scope
FROM 
    Lectures l
JOIN
    lecture_materials lm on l.Lecture_materialsID = lm.lecture_materialsID
  
JOIN 
    Enrollments e ON l.lectureID = e.lectureID
WHERE 
    l.lectureID = ?;
       
            `, [lectureId]);

            // 강의 목차 조회
        const lecturecontentTitle = await pool.query(`
        SELECT 
            lc.contentTitle
        FROM 
            LectureContents lc
        JOIN 
            Lectures l ON lc.lectureID = l.lectureID
        WHERE 
            l.lectureID = ?;
        `,[lectureId]);
            
            // 강사 정보 조회
            const instructorInfoResult = await pool.query(`
                SELECT 
                    i.InstructorName,
                    i.InstructorText
                    
                FROM 
                    instructor i
                JOIN 
                    Lectures l ON i.InstructorID = l.InstructorID
                WHERE 
                    l.lectureID = ?;
            `, [lectureId]);

            
            // 결과 합치기
            const response = {
                lectureInfo: lectureInfoResult[0],
                lectureMaterialsActive: { Lecture_materials_Active: 0 }, // 강의자료 비활성화
                instructorInfo: instructorInfoResult[0],
                lecturecontentTitle: lecturecontentTitle.map(item => item.contentTitle)
            };

            // 응답
            res.json({
                success: true,
                Message: "응답 성공",
                lectureInfo: lectureInfoResult[0],
                lectureMaterialsActive: { Lecture_materials_Active: 0 }, // 강의자료 비활성화
                instructorInfo: instructorInfoResult[0],
                lecturecontentTitle: lecturecontentTitle.map(item => item.contentTitle)
            });
            return;
        } else{
            console.log(lectureId);
            console.log(userEmail);
            // 1. 강의 기본 정보 조회
            const lectureInfoQuery = `
            SELECT 
    lm.lecture_materialsType,
    lm.lecture_materialsURL,
    l.lectureTitle,
    l.lectureText,
    l.Lecture_materialsID,
    l.Lecture_image_URL,
    l.price,
    AVG(e.scope) AS average_scope
FROM 
    Lectures l
JOIN
    lecture_materials lm on l.Lecture_materialsID = lm.lecture_materialsID
  
JOIN 
    Enrollments e ON l.lectureID = e.lectureID
WHERE 
    l.lectureID = ?;
            `;
            const lectureInfoResult = await pool.query(lectureInfoQuery, [lectureId]);


            // 강의 목차 조회
        const lecturecontentTitle = await pool.query(`
        SELECT 
            lc.contentTitle
        FROM 
            LectureContents lc
        JOIN 
            Lectures l ON lc.lectureID = l.lectureID
        WHERE 
            l.lectureID = ?;
        `,[lectureId]);

            // 2. 강의자료 활성화 여부 조회
            const lectureMaterialsQuery = `
            SELECT 
                CASE
                    WHEN e.ispurchased = 1 THEN 1
                    ELSE 0
                END AS Lecture_materials_Active
            FROM 
                Enrollments e
            WHERE 
                e.lectureID = ?
                AND e.userEmail = ?;
            `;
            const lectureMaterialsResult = await pool.query(lectureMaterialsQuery, [lectureId, userEmail]);

            // 3. 강사 정보 조회
            const instructorInfoQuery = `
                SELECT 
                    i.InstructorName,
                    i.InstructorText
                FROM 
                    instructor i
                JOIN 
                    Lectures l ON i.InstructorID = l.InstructorID
                WHERE 
                    l.lectureID = ?;
            `;
            const instructorInfoResult = await pool.query(instructorInfoQuery, [lectureId]);

            // 결과 합치기
            const response = {
                success: true,
                lectureInfo: lectureInfoResult[0],
                lectureMaterialsActive: lectureMaterialsResult[0],
                instructorInfo: instructorInfoResult[0],
                lecturecontentTitle: lecturecontentTitle.map(item => item.contentTitle)

            };

            // 결과가 하나라도 없으면 응답 실패유저   userEmail정보없을떄 if문으로 추가하기
            console.log(response);
            if (
                !response.lectureInfo ||
                !response.instructorInfo||
                !response.lecturecontentTitle
            ) {
                res.json({
                    success: false,
                    Message: "응답 실패"
                });
            } else {
                console.log();
                res.json({
                    success: true,
                    Message: "응답 성공",
                    lectureInfo: lectureInfoResult[0],
                    lectureMaterialsActive: lectureMaterialsResult,
                    instructorInfo: instructorInfoResult[0],
                    lecturecontentTitle: lecturecontentTitle.map(item => item.contentTitle)
                });
            }
        }
    } catch (error) {
        // 각각의 쿼리에서 오류가 날 경우 클라이언트에게 전달
        if (error.sqlMessage) {
            // 쿼리 오류를 서버 콘솔에 출력
            console.error(`쿼리 오류: ${error.sqlMessage}`);
    
            // 클라이언트에게 500 상태 코드와 오류 메시지 응답
            res.status(500).json({
                success: false,
                Message: `쿼리 오류: ${error.sqlMessage}`
            });
        } else {
            // 그 외의 오류를 서버 콘솔에 출력
            console.error(error);
    
            // 클라이언트에게 500 상태 코드와 일반 오류 메시지 응답
            res.status(500).json({
                success: false,
                Message: 'Internal Server Error'
            });
        }
    }
    
});

module.exports = router;


