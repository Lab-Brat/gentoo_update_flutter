const admin = require("firebase-admin");
const functions = require("firebase-functions");
const crypto = require("crypto");

const MASTER_KEY = functions.config().encryption.key;

function encryptWithMasterKey(data) {
  const nonce = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv(
      "aes-256-gcm",
      Buffer.from(MASTER_KEY, "hex"),
      nonce);

  let encrypted = cipher.update(data, "utf8", "hex");
  encrypted += cipher.final("hex");

  const tag = cipher.getAuthTag();

  return {
    iv: nonce.toString("hex"),
    content: encrypted,
    tag: tag.toString("hex"),
  };
}

function decryptWithMasterKey(encrypted) {
  if (!encrypted || !encrypted.iv || !encrypted.tag || !encrypted.content) {
    throw new Error("Invalid or incomplete encrypted data provided.");
  }

  const decipher = crypto.createDecipheriv(
      "aes-256-gcm",
      Buffer.from(MASTER_KEY, "hex"),
      Buffer.from(encrypted.iv, "hex"));
  decipher.setAuthTag(Buffer.from(encrypted.tag, "hex"));

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
  const nonce = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv(
      "aes-256-gcm",
      Buffer.from(userKey, "utf8"),
      nonce);

  let encrypted = cipher.update(data, "utf8", "hex");
  encrypted += cipher.final("hex");

  const tag = cipher.getAuthTag();

  return {
    iv: nonce.toString("hex"),
    content: encrypted,
    tag: tag.toString("hex"),
  };
}

function decryptWithUserKey(userKey, encrypted) {
  const decipher = crypto.createDecipheriv(
      "aes-256-gcm",
      Buffer.from(userKey, "utf8"),
      Buffer.from(encrypted.iv, "hex"));
  decipher.setAuthTag(Buffer.from(encrypted.tag, "hex"));

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
