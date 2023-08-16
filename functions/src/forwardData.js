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

    const userReportsRef = admin.firestore()
        .collection("reports")
        .doc(tokenDoc.id)
        .collection("user_reports");

    const newReportRef = await userReportsRef.add({
      create_date: admin.firestore.FieldValue.serverTimestamp(),
      report_status: updateStatus,
      report_content: updateContent,
    });

    console.log("Report stored with ID:", newReportRef.id);

    const message = {
      notification: {
        title: "New Report Available",
        body: `Update Status: ${updateStatus}`,
      },
      token: token,
    };

    const response = await admin.messaging().send(message);
    console.log("Successfully sent message to: " + tokenDoc.id, response);
  } catch (error) {
    console.error("Error in forwardData:", error);
  }
};

module.exports = forwardData;
