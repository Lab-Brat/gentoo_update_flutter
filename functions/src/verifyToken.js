const admin = require("firebase-admin");
const encryption = require("./encryption");
const db = admin.firestore();

const verifyToken = async (encryptedToken) => {
  const tokensRef = db.collection("tokens");
  const allTokensSnapshot = await tokensRef.get();

  if (allTokensSnapshot.empty) {
    throw new Error("Token not found");
  }

  for (const doc of allTokensSnapshot.docs) {
    const userData = doc.data();
    const userKey = await Buffer.from(
        encryption.fetchUserAESKey(doc.id), "hex");
    const decryptedTokenId = encryption.decryptWithUserKey(
        userKey,
        userData.token_id);

    if (decryptedTokenId === encryptedToken) {
      return doc;
    }
  }

  throw new Error("Token not found");
};

module.exports = verifyToken;
