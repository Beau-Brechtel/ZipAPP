const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret);

const createDriverAccount = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "The function must be called while authenticated."
        );
    }

    const driverUid = context.auth.uid;

    try {
        // Create a Stripe Connect account for the driver
        const account = await stripe.accounts.create({
            type: "express", // Use "express" for a simpler onboarding flow
            country: "US", // Change this to the driver's country
            email: data.email, // Driver's email
            capabilities: {
                transfers: { requested: true }, // Enable payouts
            },
        });

        // Store the Stripe Account ID in Firestore
        await admin.firestore().collection("drivers").doc(driverUid).set(
            {
                stripeAccountId: account.id,
            },
            { merge: true }
        );

        // Generate an Account Link for onboarding
        const accountLink = await stripe.accountLinks.create({
            account: account.id,
            refresh_url: data.refreshUrl, // URL to redirect the driver if onboarding fails
            return_url: data.returnUrl, // URL to redirect the driver after successful onboarding
            type: "account_onboarding",
        });

        return { success: true, url: accountLink.url };
    } catch (error) {
        console.error("Error creating Stripe account:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Unable to create Stripe account."
        );
    }
});

module.exports = createDriverAccount;