const admin = require("firebase-admin");
const crypto = require("crypto");

function generateToken() {
  return crypto.randomBytes(10).toString("hex");
}

module.exports = (user) => {
  const currentTime = admin.firestore.Timestamp.now();
  const tokenId = generateToken();

  const data = {
    token_id: tokenId,
    create_date: currentTime,
    last_used: currentTime,
    use_times: 1,
  };

  return admin.firestore().collection("tokens").doc(user.uid).set(data);
};
