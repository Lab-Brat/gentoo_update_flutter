const admin = require("firebase-admin");

const updateFCMToken = async (req, res) => {
  try {
    const idToken = req.body.idToken;
    const fcmToken = req.body.fcmToken;

    if (!idToken || !fcmToken) {
      res.status(400).send("ID Token and FCM Token are required.");
      return;
    }

    // Verify the ID token first.
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const uid = decodedToken.uid;

    const fcmTokenRef = admin.firestore().collection("fcmTokens").doc(uid);

    await fcmTokenRef.set({
      "fcmToken": fcmToken,
      "fcm_token_create_time": admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});

    res.status(200).send("FCM token updated successfully.");
  } catch (error) {
    console.error("Error updating FCM token:", error);
    res.status(500).send("Internal server error.");
  }
};

module.exports = updateFCMToken;

