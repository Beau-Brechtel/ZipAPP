const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Configure the email transporter
const transporter = nodemailer.createTransport({
    service: "gmail", // Use your email provider (e.g., Gmail, Outlook, etc.)
    auth: {
        user: "zipapptestemail@gmail.com", // Replace with your email
        pass: "huuv xrsc pvmt nebu", // Replace with your email password or app-specific password
    },
});

/*
 * Cloud function to email help center
 */
const emailHelpCenter = functions.https.onCall(async (data, context) => {
    const { name, email, message } = data;

    if (!name || !email || !message) {
        return { success: false, response: "Please fill all the fields." };
    }
    
    try {
        // Store the message in Firestore
        await admin.firestore().collection("helpCenter").add({
            name,
            email,
            message,
            createdAt: admin.firestore.FieldValue.serverTimestamp(), // Use Firestore server timestamp
        });
    
        // Send an email to the help center
        const mailOptions = {
            from: `"Help Center Service" zipapptestemail@gmail.com`, // Use the service email
            to: "info@zipgameday.com", // Help center email address
            replyTo: email, // User's email for reply-to
            subject: "Help Center Inquiry",
            text: `You have received a new inquiry from a user:\n\nName: ${name}\nEmail: ${email}\n\nMessage:\n${message}`,
        };
    
        await transporter.sendMail(mailOptions);
    
        return { success: true, response: "Your message has been sent successfully." };
    } catch (error) {
        console.error("Error in emailHelpCenter function:", error);
        return { success: false, response: "An error occurred while sending your message." };
    }
});

module.exports = { emailHelpCenter };