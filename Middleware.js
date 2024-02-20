// const jwt = require('jsonwebtoken');

// const authenticateToken = (req, res, next) => {
//   const cookieHeader = req.headers.cookie;

//   if (!cookieHeader) {
//     return res.status(401).json("Not authenticated!1");
//   }

//   const tokenRow = cookieHeader.split('; ').find(row => row.startsWith('access_token='));

//   if (!tokenRow) {
//     return res.status(401).json("Not authenticated!2");
//   }

//   const token = tokenRow.split('=')[1];

//   if (!token) {
//     return res.status(401).json("Not authenticated!3");
//   }

//   jwt.verify(token, "login_key", (err, userInfo) => {
//     if (err) return res.status(403).json("Token is not valid!");
//     req.user = userInfo;
//     next();
//   });
// };

// module.exports = { authenticateToken };
