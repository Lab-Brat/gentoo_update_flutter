const functions = require("firebase-functions");
const admin = require("firebase-admin");

const updateFCMToken = async (data, context) => {
  console.log("Received data:", data);
  const idToken = data.idToken;
  const fcmToken = data.fcmToken;

  if (!idToken || !fcmToken) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "ID Token and FCM Token are required.");
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    const fcmTokenRef = admin.firestore().collection("fcmTokens").doc(uid);

    await fcmTokenRef.set({
      "fcmToken": fcmToken,
      "fcm_token_create_time": admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});

    return {result: "FCM token updated successfully."};
  } catch (error) {
    console.error("Error updating FCM token:", error);
    throw new functions.https.HttpsError("internal", "Internal server error.");
  }
};

module.exports = updateFCMToken;
