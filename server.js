const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const userRouter = require('./router/user');
const mainpageRouter = require('./router/mainpage');
const totallectureRouter = require('./router/totallecture');
const shoppingbasket = require('./router/shoppingbasket');
const lectureDetails = require('./router/lecturedetail');
const lecturevideo = require('./router/lecturevideo');
// const cookieParser = require('cookie-parser');


// Middleware.js를 불러옴
// const { authenticateToken } = require('./Middleware');
// app.use(cookieParser());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/user', userRouter);//
app.use('/mainpage', mainpageRouter);
app.use('/totallecture', totallectureRouter);
app.use('/basket', shoppingbasket);
app.use('/lecturedetail', lectureDetails);
app.use('/lecturevideo', lecturevideo);

const port = 3010;

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
