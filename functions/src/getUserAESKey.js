const functions = require("firebase-functions");
const admin = require("firebase-admin");
const encryption = require("./encryption");
const db = admin.firestore();

const getUserAESKey = async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated", "User must be authenticated to fetch AES key.");
  }

  const authenticatedUID = context.auth.uid;
  const docRef = db.collection("tokens").doc(authenticatedUID);
  const doc = await docRef.get();

  if (!doc.exists) {
    console.error("Document for user", authenticatedUID, "not found!");
    throw new functions.https.HttpsError(
        "not-found", "No corresponding AES key found for this user.");
  }

  const userAESKey = doc.data().user_aes_key;

  if (!userAESKey) {
    console.error("user_aes_key field missing for user", authenticatedUID);
    throw new functions.https.HttpsError(
        "data-missing", "user_aes_key field missing for user.");
  }

  if (!userAESKey.content || !userAESKey.iv || !userAESKey.tag) {
    console.error(
        "One of the required fields in user_aes_key is missing for user",
        authenticatedUID);
    throw new functions.https.HttpsError(
        "data-missing", "Required fields in user_aes_key missing.");
  }

  console.log("userAESKey.content:", userAESKey.content);
  const decryptedContent = encryption.decryptWithMasterKey(userAESKey);

  const response = {
    content: decryptedContent,
    iv: userAESKey.iv,
    tag: userAESKey.tag,
  };
  return response;
};


module.exports = getUserAESKey;
