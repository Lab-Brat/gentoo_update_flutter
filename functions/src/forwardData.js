const admin = require("firebase-admin");

const forwardData = async (tokenDoc, updateStatus, updateContent) => {
  try {
    const fcmTokenRef = admin.firestore().collection("fcmTokens").doc(
        tokenDoc.id);
    const fcmTokenDoc = await fcmTokenRef.get();

    if (!fcmTokenDoc.exists) {
      console.error("No FCM token found for this user.");
      return;
    }

    const fcmTokenData = fcmTokenDoc.data();
    const token = fcmTokenData.fcmToken;

    const message = {
      notification: {
        title: `Update Status: ${updateStatus}`,
        body: updateContent,
      },
      token: token,
    };

    const response = await admin.messaging().send(message);
    console.log("Successfully sent message to: " + tokenDoc.id, response);
  } catch (error) {
    console.error("Error sending message:", error);
  }
};

module.exports = forwardData;
