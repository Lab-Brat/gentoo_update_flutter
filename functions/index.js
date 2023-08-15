const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const addNewUser = require("./src/addNewUser");
exports.addNewUser = functions.auth.user().onCreate(addNewUser);

const updateFCMToken = require("./src/updateFCMToken");
exports.updateFCMToken = functions.https.onRequest(updateFCMToken);

exports.checkTokenAndForwardData = functions.https.onRequest(
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Invalid method");
        return;
      }

      const token = req.query.token;
      if (!token) {
        res.status(400).send("Token not provided");
        return;
      }

      const tokensRef = db.collection("tokens").doc(token);
      const tokenDoc = await tokensRef.get();
      const updateStatus = req.query.update_status;
      const updateContent = req.query.update_content;


      if (!tokenDoc.exists) {
        res.status(404).send("Token not found");
        return;
      }

      const tokenData = tokenDoc.data();
      const lastUsed = tokenData.last_used;
      let requestCount = tokenData.use_times || 0;
      const currentTime = new Date();

      if (lastUsed) {
        const timeDiff = (
          currentTime - new Date(lastUsed._seconds * 1000)) /
        (1000 * 60 * 60 * 24);
        if (timeDiff >= 1) {
          requestCount = 0;
        } else if (requestCount >= 5) {
          res.status(429).send("Rate limit exceeded");
          return;
        }
      }

      await tokensRef.update({
        "last_used": currentTime,
        "use_times": requestCount + 1,
      });

      const fcmToken = tokenData.fcm_token;
      if (fcmToken) {
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
        }
      } else {
        console.log("No FCM token found for this user.");
      }


      res.status(200).send("Data forwarded successfully");
    });
