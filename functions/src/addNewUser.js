const admin = require("firebase-admin");
const encryption = require("./encryption");
const crypto = require("crypto");

function generateToken() {
  return crypto.randomBytes(4).toString("hex");
}

function generateUserAESKey() {
  return crypto.randomBytes(32).toString("hex");
}

module.exports = async (user) => {
  try {
    const currentTime = admin.firestore.Timestamp.now();
    const tokenId = generateToken();
    const userAESKey = generateUserAESKey();
    console.log("Original User Info:");
    console.log(userAESKey);
    console.log(tokenId);

    const encryptedUserAESKey = encryption.encryptWithMasterKey(userAESKey);

    const data = {
      token_id: encryption.encryptWithUserKey(userAESKey, tokenId).content,
      create_date: currentTime,
      last_used: currentTime,
      use_times: 1,
      user_aes_key: encryptedUserAESKey,
    };

    return admin.firestore().collection("tokens").doc(user.uid).set(data);
  } catch (error) {
    console.error("Error in addNewUser:", error);
    throw error;
  }
};
