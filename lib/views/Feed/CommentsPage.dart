import 'package:achievement_view/achievement_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:schatty/helper/constants.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/TargetUserInfo.dart';
import 'package:schatty/widgets/widget.dart';

class CommentsPage extends StatefulWidget {
  final postUID;
  final tag;

  const CommentsPage({
    Key key,
    @required this.postUID,
    @required this.tag,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String id;
  Stream<QuerySnapshot> commentSnap;

  bool isSelected = false;
  String selectedUsername;
  String selectedComment;
  String ranString;
  String selectedCID;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupSnap();
    selectedUsername = null;
    selectedComment = null;
    isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schatty"),
        centerTitle: true,
        actions: [
          isSelected && selectedUsername == Constants.ownerName.toLowerCase()
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteComment(context);
                  },
                )
              : SizedBox(),
          isSelected
              ? IconButton(
                  icon: Icon(Icons.report),
                  onPressed: () {
                    reportComment();
                  },
                )
              : SizedBox(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCommentBox(context);
        },
        child: Icon(
          Icons.add,
          size: 35,
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: commentSnap,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text("Error: ${snapshot.hasError}");
            if (!snapshot.hasData)
              return Center(
                  child: Text(
                "Be the first to comment!",
                style: TextStyle(fontSize: 40),
              ));
            return snapshot.data.documents.length != 0
                ? ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return CommentTile(
                        context,
                        snapshot.data.documents[index].data['photoURL'],
                        snapshot.data.documents[index].data['username'],
                        snapshot.data.documents[index].data['commentId'],
                        snapshot.data.documents[index].data['comment'],
                      );
                    })
                : Center(
                    child: Text(
                    "Be the first to comment!",
                    style: TextStyle(fontSize: 40),
                  ));
          },
        ),
      ),
    );
  }

  //Widgets
  TextEditingController commentTEC = new TextEditingController();

  showCommentBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Comment"),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: MediaQuery.of(context).size.height * 0.1,
              child: TextFormField(
                autofocus: true,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(23))),
                textCapitalization: TextCapitalization.sentences,
                controller: commentTEC,
                maxLines: 3,
                maxLength: 150,
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                    alignment: Alignment.center, child: Text("Cancel")),
              ),
              FlatButton(
                onPressed: () {
                  addComment(
                      commentTEC.text, Constants.ownerName.toLowerCase());
                  Navigator.pop(context);
                },
                child:
                    Container(alignment: Alignment.center, child: Text("Add")),
              )
            ],
          );
        });
  }

  // ignore: non_constant_identifier_names
  Widget CommentTile(BuildContext context, String url, String username,
      String id, String commentContent) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            isSelected = false;
            selectedComment = null;
            selectedUsername = null;
            selectedCID = null;
          });
        }
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        if (mounted) {
          setState(() {
            isSelected = true;
            selectedUsername = username;
            selectedComment = commentContent;
            selectedCID = id;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          color: isSelected &&
                  selectedUsername == username &&
                  selectedComment == commentContent
              ? Color.fromARGB(153, 126, 217, 241)
              : null,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TargetUserInfo(username))),
                  child: UserAvatar(url, 20),
                ),
              ),
              Container(
                child: Text(
                  username,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  commentContent,
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //Functions

  reportComment() async {
    Map<String, dynamic> reportCommentMap = {
      'reportedBy': Constants.ownerName.toLowerCase(),
      'commentId': selectedCID,
      'tag': widget.tag,
      'postId': widget.postUID,
    };

    await Firestore.instance
        .collection('Reported')
        .document('Posts')
        .collection('ReportedComments')
        .add(reportCommentMap);
    setState(() {
      isSelected = false;
      selectedComment = null;
      selectedUsername = null;
      selectedCID = null;
      AchievementView(
        context,
        title: "Reported",
        duration: Duration(seconds: 1, milliseconds: 500),
        subTitle: "The comment has been reported. Thank you!",
        listener: (status) {
          print(status);
        },
        icon: Icon(Icons.report),
        color: Color(0xff3B3B3B),
      )..show();
    });
    Fluttertoast.showToast(msg: "Reported", gravity: ToastGravity.CENTER);
  }

  getRandom() {
    ranString = randomString(8);
  }

  addComment(String comment, String username) async {
    try {
      getRandom();
      Map<String, dynamic> commentMap = {
        'comment': comment,
        'username': username,
        'photoURL': await databaseMethods.getProfileUrlByName(username),
        'commentId': ranString,
      };
      await Firestore.instance
          .collection('Posts')
          .document('Public')
          .collection(widget.tag)
          .where('postUid', isEqualTo: widget.postUID)
          .getDocuments()
          .then((docs) {
        Firestore.instance
            .collection('Posts')
            .document('Public')
            .collection(widget.tag)
            .document(docs.documents[0].documentID)
            .collection('comments')
            .add(commentMap);
      });
      if (mounted) {
        setState(() {
          Fluttertoast.showToast(
              msg: "Comment added!", gravity: ToastGravity.CENTER);
        });
      }
    } catch (error) {
      print("Error adding comment: $error");
    }
  }

  deleteComment(BuildContext context) async {
    try {
      await Firestore.instance
          .collection('Posts')
          .document('Public')
          .collection(widget.tag)
          .where('postUid', isEqualTo: widget.postUID)
          .getDocuments()
          .then((docs) {
        Firestore.instance
            .collection('Posts')
            .document('Public')
            .collection(widget.tag)
            .document(docs.documents[0].documentID)
            .collection('comments')
            .where('commentId', isEqualTo: selectedCID)
            .getDocuments()
            .then((docs2) async {
          await Firestore.instance
              .collection('Posts')
              .document('Public')
              .collection(widget.tag)
              .document(docs.documents[0].documentID)
              .collection('comments')
              .document(docs2.documents[0].documentID)
              .delete()
              .whenComplete(() {
            setState(() {
              AchievementView(
                context,
                title: "Deleted",
                subTitle: "The comment has been deleted",
                listener: (status) {
                  print(status);
                },
                duration: Duration(seconds: 1, milliseconds: 500),
                icon: Icon(Icons.delete_forever),
                color: Color(0xff3B3B3B),
              )..show();
              isSelected = false;
              selectedUsername = null;
              selectedComment = null;
              selectedCID = null;
            });
          });
        });
      });
    } catch (error) {
      print("Error deleting comment: $error");
    }
  }

  getPostComments() {
    Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(widget.tag)
        .where('postUid', isEqualTo: widget.postUID)
        .getDocuments()
        .then((docs) {
      Firestore.instance
          .collection('Posts')
          .document('Public')
          .collection(widget.tag)
          .document(docs.documents[0].documentID)
          .collection('comments')
          .getDocuments();
    });
  }

  setupSnap() async {
    await Firestore.instance
        .collection('Posts')
        .document('Public')
        .collection(widget.tag)
        .where('postUid', isEqualTo: widget.postUID)
        .getDocuments()
        .then((value) {
      id = value.documents[0].documentID;
    });
    setState(() {
      commentSnap = Firestore.instance
          .collection('Posts')
          .document('Public')
          .collection(widget.tag)
          .document(id)
          .collection('comments')
          .snapshots();
    });
  }
}
