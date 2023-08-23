const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const addNewUser = require("./src/addNewUser");
exports.addNewUser = functions.auth.user().onCreate(addNewUser);

const updateFCMToken = require("./src/updateFCMToken");
exports.updateFCMToken = functions.https.onCall(updateFCMToken);

const getUserAESKey = require("./src/getUserAESKey");
exports.getUserAESKey = functions.https.onCall(getUserAESKey);

const forwardData = require("./src/forwardData");
const verifyToken = require("./src/verifyToken");
const rateLimit = require("./src/rateLimit");
const encryption = require("./src/encryption");

exports.checkTokenAndForwardData = functions.https.onRequest(
    async (req, res) => {
      try {
        if (req.method !== "POST") {
          res.status(405).send("Invalid method");
          return;
        }

        const encryptedToken = req.body.token;
        const UpdateStatus = req.body.update_status;
        const UpdateContent = req.body.update_content;

        if (!encryptedToken) {
          res.status(400).send("Token not provided");
          return;
        }

        const tokenDoc = await verifyToken(encryptedToken);
        const userKeyEncrypted = tokenDoc.data().user_aes_key;
        const userKey = encryption.decryptWithMasterKey(userKeyEncrypted);

        const encryptedUpdateContent = encryption.encryptWithUserKey(
            userKey, JSON.stringify(UpdateContent)).content;

        await rateLimit(tokenDoc);
        await forwardData(
            tokenDoc,
            UpdateStatus,
            encryptedUpdateContent);

        res.status(200).send("Data forwarded successfully");
      } catch (error) {
        if (error.message === "Token not found") {
          res.status(404).send(error.message);
        } else if (error.message === "Rate limit exceeded") {
          res.status(429).send(error.message);
        } else {
          console.error("Unknown error:", error);
          res.status(500).send("Internal server error.");
        }
      }
    });
