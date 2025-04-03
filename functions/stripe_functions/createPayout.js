const functions = require("firebase-functions");
const stripe = require("stripe")(functions.config().stripe.secret);

const createPayout = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated."
        );
    }

    const driverUid = context.auth.uid;

    try {
        // Retrieve the driver's Stripe Account ID from Firestore
        const driverDoc = await admin.firestore().collection("drivers").doc(driverUid).get();
        const stripeAccountId = driverDoc.data().stripeAccountId;

        if (!stripeAccountId) {
            throw new functions.https.HttpsError(
                "failed-precondition",
                "Driver does not have a Stripe account."
            );
        }

        // Create a transfer to the driver's Stripe account
        const transfer = await stripe.transfers.create({
            amount: data.amount, // Amount in cents
            currency: "usd",
            destination: stripeAccountId,
        });

        return { success: true, transfer };
    } catch (error) {
        console.error("Error creating payout:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Unable to create payout."
        );
    }
});

module.exports = { createPayout };