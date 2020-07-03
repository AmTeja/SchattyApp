const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotification = functions.region('asia-east2').firestore
       .document('/ChatRoom/{ChatRoomId}/chats/{chatId}').onCreate((snap, context) => {
           const doc = snap.data()
           const idFrom = doc.sentFrom
           const idTo = doc.sendTo
           const contentMessage = doc.message
           const imageUrl = doc.url

           admin
                .firestore()
                .collection('tokens')
                .where('uid', '==',idTo)
                .get()
                .then(querySnapshot => {
                    querySnapshot.forEach(userTo => {
                    const toUsername = userTo.data().username
                    const toToken = userTo.data().token
                        if(toToken && userTo.data().sendTo !== idFrom){
                            admin
                                .firestore()
                                .collection('tokens')
                                .where("uid", "==", idFrom)
                                .get()
                                .then(querySnapshot2 => {
                                    querySnapshot2.forEach(userFrom => {
                                        const fromUsername = userFrom.data().username
                                        const payload = {
                                            notification: {
                                                title: fromUsername,
                                                body:  contentMessage,
                                                badge: '1',
                                                sound: 'default',
                                                image: imageUrl,
                                            },
                                            data: {
                                                click_action: "FLUTTER_NOTIFICATION_CLICK",
                                                sentUser: fromUsername,
                                                toUser: toUsername,
                                            }
                                        }

                                        admin
                                        .messaging()
                                        .sendToDevice(userTo.data().token, payload)
                                        .then(response => {
                                            console.log('Successfully sent message: ',response)
                                        })
                                        .catch(error => {
                                            console.log('Error sending message:', error)
                                        })
                                    })
                                })
                        } else{
                            console.log('Cannot find token for target user')
                        }
                    })
                })
                return null
       }) 