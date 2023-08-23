const admin = require("firebase-admin");
const encryption = require("./encryption");
const db = admin.firestore();

const verifyToken = async (tokenID) => {
  const tokensRef = db.collection("tokens");
  const allTokensSnapshot = await tokensRef.get();

  if (allTokensSnapshot.empty) {
    throw new Error("Token not found");
  }

  for (const doc of allTokensSnapshot.docs) {
    const userData = doc.data();
    const userAESKey = userData.user_aes_key;
    const decryptedAESKey = encryption.decryptWithMasterKey(userAESKey);

    const tokenIDIV = {
      iv: userData.token_id_iv,
      content: userData.token_id,
    };
    const decryptedTokenId = encryption.decryptWithUserKey(
        decryptedAESKey,
        tokenIDIV);

    if (decryptedTokenId === tokenID) {
      return doc;
    }
  }

  throw new Error("Token not found");
};

module.exports = verifyToken;
