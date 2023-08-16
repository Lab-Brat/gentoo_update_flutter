const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const addNewUser = require("./src/addNewUser");
exports.addNewUser = functions.auth.user().onCreate(addNewUser);

const updateFCMToken = require("./src/updateFCMToken");
exports.updateFCMToken = functions.https.onRequest(updateFCMToken);

const forwardData = require("./src/forwardData");
const verifyToken = require("./src/verifyToken");
const rateLimit = require("./src/rateLimit");
exports.checkTokenAndForwardData = functions.https.onRequest(
    async (req, res) => {
      try {
        if (req.method !== "POST") {
          res.status(405).send("Invalid method");
          return;
        }

        const token = req.body.token;
        const updateStatus = req.body.update_status;
        const updateContent = req.body.update_content;

        if (!token) {
          res.status(400).send("Token not provided");
          return;
        }

        const tokenDoc = await verifyToken(token);

        await rateLimit(tokenDoc);
        await forwardData(tokenDoc, updateStatus, updateContent);

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
