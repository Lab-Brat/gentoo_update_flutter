const rateLimit = async (tokenDoc) => {
  const tokenData = tokenDoc.data();
  const lastUsed = tokenData.last_used;
  let requestCount = tokenData.use_times || 0;
  const currentTime = new Date();

  if (lastUsed) {
    const timeDiff = (currentTime -
      new Date(lastUsed._seconds * 1000)) /
      (1000 * 60 * 60 * 24);
    if (timeDiff >= 1) {
      requestCount = 0;
    } else if (requestCount >= 11) {
      throw new Error("Rate limit exceeded");
    }
  }

  await tokenDoc.ref.update({
    "last_used": currentTime,
    "use_times": requestCount + 1,
  });
};

module.exports = rateLimit;
