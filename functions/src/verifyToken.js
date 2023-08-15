const admin = require("firebase-admin");
const db = admin.firestore();

const verifyToken = async (token) => {
  const tokensRef = db.collection("tokens").doc(token);
  const tokenDoc = await tokensRef.get();

  if (!tokenDoc.exists) {
    throw new Error("Token not found");
  }

  return tokenDoc;
};

module.exports = verifyToken;
