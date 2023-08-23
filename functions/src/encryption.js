const admin = require("firebase-admin");
const functions = require("firebase-functions");
const crypto = require("crypto");

const MASTER_KEY = functions.config().encryption.key;

function encryptWithMasterKey(data) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(
      "aes-256-cbc",
      Buffer.from(MASTER_KEY, "hex"),
      iv);

  let encrypted = cipher.update(data, "utf8", "hex");
  encrypted += cipher.final("hex");

  return {
    iv: iv.toString("hex"),
    content: encrypted,
  };
}

function decryptWithMasterKey(encrypted) {
  const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      Buffer.from(MASTER_KEY, "hex"),
      Buffer.from(encrypted.iv, "hex"));

  let decrypted = decipher.update(encrypted.content, "hex", "utf8");
  decrypted += decipher.final("utf8");

  return decrypted;
}


async function fetchUserAESKey(userId) {
  const userDoc = await admin.firestore()
      .collection("tokens").doc(userId).get();

  if (!userDoc.exists) {
    throw new Error("No user found.");
  }

  const encryptedUserAESKey = userDoc.data().user_aes_key;
  return decryptWithMasterKey(encryptedUserAESKey);
}

function encryptWithUserKey(userKey, data) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(
      "aes-256-cbc",
      Buffer.from(userKey, "hex"),
      iv);

  let encrypted = cipher.update(data, "utf8", "hex");
  encrypted += cipher.final("hex");

  return {
    iv: iv.toString("hex"),
    content: encrypted,
  };
}

function decryptWithUserKey(userKey, encrypted) {
  const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      Buffer.from(userKey, "hex"),
      Buffer.from(encrypted.iv, "hex"));

  let decrypted = decipher.update(encrypted.content, "hex", "utf8");
  decrypted += decipher.final("utf8");

  return decrypted;
}

module.exports = {
  encryptWithMasterKey,
  decryptWithMasterKey,
  fetchUserAESKey,
  encryptWithUserKey,
  decryptWithUserKey,
};
