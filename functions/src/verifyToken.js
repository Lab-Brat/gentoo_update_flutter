const admin = require("firebase-admin");
const db = admin.firestore();

const verifyToken = async (token) => {
  const tokensRef = db.collection("tokens");
  const snapshot = await tokensRef.where("token_id", "==", token).get();

  if (snapshot.empty) {
    throw new Error("Token not found");
  }

  return snapshot.docs[0];
};

module.exports = verifyToken;
