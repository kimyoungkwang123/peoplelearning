const express = require('express');
const { pool } = require('../database/mariadb');
const router = express.Router();

// 강의 목차
router.get('/', async (req, res) => {
    const lectureID = req.query.lectureID; 

    try {
        // 강의 화면 및 하위 목차 영상 시간 조회 쿼리
        const query = `
            SELECT 
                lc.contentTitle,
                sltc.table_of_contents_of_sub_lecturesID,
                sltc.table_of_contents_of_sub_lecturesTitle,
                sltc.video_time,
                sltc.video_url
            FROM 
                LectureContents lc
            JOIN 
                sub_lecture_table_of_contents sltc ON lc.contentID = sltc.contentID
            WHERE 
                lc.lectureID = ?;
        `;
        const result = await pool.query(query, [lectureID]);

        if (result && result.length > 0) {
            res.json({
                code: 200,
                message: '성공',
                data: result
            });
        } else {
            res.json({
                code: 401,
                message: '실패'
            });
        }
    } catch (error) {
        console.error('Error retrieving data:', error);
        res.status(500).json({
            success: false,
            message: '데이터를 가져오는 도중 오류가 발생했습니다.'
        });
    }
});


// 각각의 영상 조회
router.get('/videoDetail', async (req, res) => {
    const table_of_contents_of_sub_lecturesID = req.query.table_of_contents_of_sub_lecturesID;

    try {
        const lecturevideoQuery = `
            SELECT 
                l.lectureTitle,
                t.table_of_contents_of_sub_lecturesTitle,
                t.video_time,
                t.video_url
            FROM 
                LectureContents lc
            JOIN
                Lectures l on lc.lectureID = l.lectureID
            JOIN 
                sub_lecture_table_of_contents t ON lc.contentID = t.contentID
            WHERE 
                t.table_of_contents_of_sub_lecturesID = ?;
        `;
        const lecturevideoResult = await pool.query(lecturevideoQuery, [table_of_contents_of_sub_lecturesID]);
        console.log(lecturevideoResult)

        if (lecturevideoResult.length > 0) {
            res.json({
                code: 200,
                message: '성공',
                data: lecturevideoResult
            });
        } else {
            res.json({
                code: 401,
                message: '실패'
            });
        }
        
    } catch (error) {
        console.error('Error retrieving video detail data:', error);
        res.status(500).send('Internal Server Error');
    }
});


// 게시글 조회
router.get('/board', async (req, res) => {
    try {
        const boardQuery = `
            SELECT 
                b.boardID,
                b.boardTitle,
                b.boardText,
                b.boardTime,
                b.boardLike,
                b.boardUnlike,
                b.boardCount,
                u.userName,
                (SELECT COUNT(*) FROM comment c WHERE c.boardID = b.boardID) AS commentCount
            FROM 
                board b
            JOIN 
                users u ON b.userEmail = u.userEmail
            ORDER BY 
                b.boardTime DESC
            LIMIT 10;
        `;
        const boardResult = await pool.query(boardQuery);
        // console.log(boardResult);

        if (boardResult && boardResult.length > 0) {
            res.json({
                code: 200,
                message: '성공',
                data: boardResult
            });
        } else {
            res.json({
                code: 401,
                message: '실패'
            });
        }
    } catch (err) {
        console.error('Error fetching board data:', err);
        res.status(500).send('Internal Server Error');
    }
});



//게시글 상세페이지
router.get('/board/detail', async(req,res)=>{
    // const boardID = parseInt(req.query.boardID);
    const boardID = req.query.boardID;
    console.log(boardID);
    try{
        const detailQuery = `
        SELECT 
            b.boardTitle,
            b.boardText,
            b.boardTime,
            b.boardLike,
            b.boardUnlike,
            u.userName,
            b.boardCount
        FROM 
            board b
        JOIN 
            users u ON b.userEmail = u.userEmail
        WHERE 
            b.boardID = ?`;
        const boarddetail = await pool.query(detailQuery, [boardID]);        
        console.log(boarddetail);
        if(boarddetail.length>0){
            res.json({
                code: 200,
                message: '성공',
                data: boarddetail
            });
        } else {
            res.json({
                code: 401,
                message: '실패'
            });
        }
    }catch(err) {
        console.error('Error fetching board data:', err);
        res.status(500).send('Internal Server Error');
    }
});


// 좋아요 처리 엔드포인트
router.post('/board/like', async (req, res) => {
    const { boardID, userEmail } = req.body;

    try {
        // 사용자의 리액션 상태 확인
        const alreadyLiked = reactions.some(([storedBoardID, storedReactionType, storedUserEmail]) => 
            storedBoardID === boardID && storedUserEmail === userEmail && storedReactionType === 'like'
        );

        // 좋아요를 이미 한 경우에는 감소, 아닌 경우에는 증가
        if (alreadyLiked) {
            await decreaseReactionCount(boardID, 'like');
            // 이미 좋아요를 한 경우, 배열에서 해당 리액션 정보 삭제
            reactions = reactions.filter(([storedBoardID, storedReactionType, storedUserEmail]) => 
                !(storedBoardID === boardID && storedUserEmail === userEmail && storedReactionType === 'like')
            );
        } else {
            await increaseReactionCount(boardID, 'like');
            // 좋아요를 누른 경우, 배열에 해당 리액션 정보 추가
            reactions.push([boardID, 'like', userEmail]);
        }

        res.json({
            code: 200,
            message: '좋아요 처리가 완료되었습니다.',
        });
    } catch (error) {
        console.error('좋아요 처리 중 에러가 발생했습니다:', error);
        res.status(500).send('내부 서버 오류가 발생했습니다.');
    }
});

// 싫어요 처리 엔드포인트
router.post('/board/unlike', async (req, res) => {
    const { boardID, userEmail } = req.body;

    try {
        // 사용자의 리액션 상태 확인
        const alreadyUnliked = reactions.some(([storedBoardID, storedReactionType, storedUserEmail]) => 
            storedBoardID === boardID && storedUserEmail === userEmail && storedReactionType === 'dislike'
        );

        // 싫어요를 이미 한 경우에는 감소, 아닌 경우에는 증가
        if (alreadyUnliked) {
            await decreaseReactionCount(boardID, 'dislike');
            // 이미 싫어요를 한 경우, 배열에서 해당 리액션 정보 삭제
            reactions = reactions.filter(([storedBoardID, storedReactionType, storedUserEmail]) => 
                !(storedBoardID === boardID && storedUserEmail === userEmail && storedReactionType === 'dislike')
            );
        } else {
            await increaseReactionCount(boardID, 'dislike');
            // 싫어요를 누른 경우, 배열에 해당 리액션 정보 추가
            reactions.push([boardID, 'dislike', userEmail]);
        }

        res.json({
            code: 200,
            message: '싫어요 처리가 완료되었습니다.',
        });
    } catch (error) {
        console.error('싫어요 처리 중 에러가 발생했습니다:', error);
        res.status(500).send('내부 서버 오류가 발생했습니다.');
    }
});




// 배열로 사용자의 리액션을 관리
let reactions = [];

// 게시글 상세페이지에서 좋아요/싫어요 처리
router.post('/board/reaction', async (req, res) => {
    const { boardID, reactionType, userEmail } = req.body;

    try {
        // 배열에 사용자의 리액션을 추가합니다.
        reactions.push([boardID, reactionType, userEmail]);

        // 배열의 길이가 30을 초과하는 경우, 가장 오래된 리액션 2개를 제거
        if (reactions.length > 30) {
            reactions.shift();
            reactions.shift(); 
        }

        // 배열에 저장된 사용자의 리액션 정보를 기반으로 리액션을 처리
let likeCount = 0;
let dislikeCount = 0;
for (let i = 0; i < reactions.length; i++) {
    const [storedBoardID, storedReactionType, storedUserEmail] = reactions[i];
    if (storedBoardID === boardID && storedUserEmail === userEmail) {
        if (storedReactionType === 'like') {
            likeCount++;
        } else if (storedReactionType === 'dislike') {
            dislikeCount++;
        }
    }
}

// 현재 사용자의 리액션 상태를 확인하여 증가 또는 감소를 결정
if (reactionType === 'like') {
    if (likeCount % 2 === 0) {
        await increaseReactionCount(boardID, 'like');
    } else {
        await decreaseReactionCount(boardID, 'like');
    }
} else if (reactionType === 'dislike') {
    if (dislikeCount % 2 === 0) {
        await increaseReactionCount(boardID, 'dislike');
    } else {
        await decreaseReactionCount(boardID, 'dislike');
    }
}


        res.json({
            code: 200,
            message: `${reactionType === 'like' ? '좋아요' : '싫어요'} 처리가 완료되었습니다.`,
        });
    } catch (error) {
        console.error('리액션 처리 중 에러가 발생했습니다:', error);
        res.status(500).send('내부 서버 오류가 발생했습니다.');
    }
});


// 게시글의 좋아요 또는 싫어요 수를 증가시키는 함수
async function increaseReactionCount(boardID, reactionType) {
    // 게시글의 좋아요 또는 싫어요 수를 증가
    const updateReactionQuery = `
        UPDATE board 
        SET ${reactionType === 'like' ? 'boardLike' : 'boardUnlike'} = ${reactionType === 'like' ? 'boardLike' : 'boardUnlike'} + 1 
        WHERE boardID = ?;
    `;
    await pool.query(updateReactionQuery, [boardID]);
}

// 게시글의 좋아요 또는 싫어요 수를 감소시키는 함수
async function decreaseReactionCount(boardID, reactionType) {
    // 게시글의 좋아요 또는 싫어요 수를 감소
    const updateReactionQuery = `
        UPDATE board 
        SET ${reactionType === 'like' ? 'boardLike' : 'boardUnlike'} = ${reactionType === 'like' ? 'boardLike' : 'boardUnlike'} - 1 
        WHERE boardID = ?;
    `;
    await pool.query(updateReactionQuery, [boardID]);
}


// 특정 게시물의 특정 리액션 수 가져오기
async function getReactionCount(boardID, reactionType) {
    const countQuery = `
        SELECT COUNT(*) AS count
        FROM user_reactions
        WHERE boardID = ? AND reactionType = ?;
    `;
    const result = await pool.query(countQuery, [boardID, reactionType]);
    return result[0].count;
}

// // 게시글 상세페이지에서 좋아요/싫어요 처리
// router.post('/board/reaction', async (req, res) => {
//     const { boardID, reactionType } = req.body;

//     try {
//         let updateField = '';
//         let oppositeField = '';
//         if (reactionType === 'like') {
//             updateField = 'boardLike';
//             oppositeField = 'boardUnlike';
//         } else if (reactionType === 'dislike') {
//             updateField = 'boardUnlike';
//             oppositeField = 'boardLike';
//         } else {
//             return res.status(400).json({
//                 code: 400,
//                 message: '유효하지 않은 reactionType입니다.'
//             });
//         }

//         // 게시물의 좋아요/싫어요 수 업데이트
//         const updateReactionQuery = `
//             UPDATE board 
//             SET ${updateField} = ${updateField} + 1,
//                 ${oppositeField} = CASE WHEN ${oppositeField} > 0 THEN ${oppositeField} - 1 ELSE ${oppositeField} END
//             WHERE boardID = ?;
//         `;
//         await pool.query(updateReactionQuery, [boardID]);

//         res.json({
//             code: 200,
//             message: `${reactionType === 'like' ? '좋아요' : '싫어요'} 처리가 완료되었습니다.`,
//         });
//     } catch (error) {
//         console.error('리액션 처리 중 에러가 발생했습니다:', error);
//         res.status(500).send('내부 서버 오류가 발생했습니다.');
//     }
// });




router.get('/board/search', async (req, res) => {
    const boardTitle = req.query.boardTitle;
    console.log(boardTitle);
    try {
        const searchQuery = `
            SELECT 
                b.boardID,
                b.boardTitle,
                b.boardText,
                b.boardTime,
                b.boardLike,
                b.boardUnlike,
                u.userName
            FROM 
                board b
            JOIN 
                users u ON b.userEmail = u.userEmail
            WHERE 
                b.boardTitle LIKE ?
            ORDER BY 
                b.boardTime DESC
            LIMIT 10;
        `;
        
        const rows = await pool.query(searchQuery, [`%${boardTitle}%`]);

        if (result && result.length > 0) {
            res.json({
                code: 200,
                message: '성공',
                data: rows
            });
        } else {
            res.json({
                code: 401,
                message: '실패'
            });
        }
    } catch (error) {
        console.error('Error searching boards:', error);
        res.status(500).send('Internal Server Error');
    }
});


module.exports = router;
