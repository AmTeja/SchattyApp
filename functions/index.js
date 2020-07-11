const functions = require('firebase-functions');

const admin = required('firebase-admin');
admin.initializeApp();

exports.sendMsgNotification = functions.firestore.document('/ChatRoom/{documentId}/chats/{message}').onCreate((snapshot, context) => {

    console.log('------------Function Start ------------')

    const doc = snapshot.data();
    console.log(doc)

    const sentFrom = doc.sentFrom
    const sentTo = doc.sendTo
    const messageContent = doc.message
    const imageUrl = doc.url

    console.log('TEst SentFrom: $sentFrom')

})