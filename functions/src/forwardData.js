const admin = require("firebase-admin");

const forwardData = async (tokenDoc, updateStatus, updateContent) => {
  const tokenData = tokenDoc.data();
  const fcmToken = tokenData.fcm_token;

  if (!fcmToken) {
    console.log("No FCM token found for this user.");
    return;
  }

  const message = {
    notification: {
      title: `Update Status: ${updateStatus}`,
      body: updateContent,
    },
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
  } catch (error) {
    console.log("Error sending message:", error);
    throw error;
  }
};

module.exports = forwardData;
