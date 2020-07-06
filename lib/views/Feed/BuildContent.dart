import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schatty/provider/DarkThemeProvider.dart';
import 'package:schatty/services/DatabaseManagement.dart';
import 'package:schatty/views/Chatroom/TargetUserInfo.dart';
import 'package:schatty/widgets/widget.dart';

class BuildPost extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final url;
  final username;
  final topic;
  final caption;
  final isDark;

  // ignore: non_constant_identifier_names
  const BuildPost({
    @required this.url,
    @required this.username,
    this.topic,
    @required this.isDark,
    this.caption,
  });

  @override
  _BuildPostState createState() => _BuildPostState();
}

class _BuildPostState extends State<BuildPost> {
  bool isLiked = false;
  bool isDisliked = false;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  String profileUrl;

  @override
  void initState() {
    // TODO: implement initState
    profileUrl = null;
    super.initState();
//    getUserProfileUrl();
  }

  @override
  Widget build(BuildContext context) {
    getUserProfileUrl();
    return Consumer<DarkThemeProvider>(
      builder: (BuildContext context, value, Widget child) {
        return Container(
            decoration: BoxDecoration(
//          color: Color(0xffeeefe1),
                color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
//        direction: Axis.vertical,
              children: [
                Header(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23)),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => viewImage(widget.url, context,
                                widget.caption, widget.caption),
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Hero(
                        tag: widget.caption,
                        child: CachedNetworkImage(
                          imageUrl: widget.url,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Footer(),
              ],
            ));
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget Header() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TargetUserInfo(widget.username),
            ));
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
//          color: widget.isDark ? Colors.black : Colors.white,
            ),
        height: 70,
        child: ListTile(
          leading: CircleAvatar(
            child: ClipOval(
              child: profileUrl != null
                  ? CachedNetworkImage(
                      width: 60,
                      height: 60,
                      imageUrl: profileUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/username.png",
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          title: widget.username != null
              ? Text(widget.username)
              : Center(
                  child: CircularProgressIndicator(),
                ),
//        subtitle: widget.topic != null ? Text("Topic: ${widget.topic}") : null,
          trailing: IconButton(
            icon: Icon(Icons.expand_more),
            splashRadius: 25.0,
            splashColor: Colors.white,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Footer() {
    double splashRadius = 25.0;
    return Container(
//      height: 80,
      decoration: BoxDecoration(
//        color: widget.isDark ? Colors.black : Colors.white,
//        borderRadius: BorderRadius.circular(23)
          border: Border(
              bottom: BorderSide(
        color: Colors.black,
      ))),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    color: isLiked ? Color(0xffFF8F8F) : null,
                    splashRadius: splashRadius,
                    onPressed: () => _liked(),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    color: isDisliked ? Color(0xffFF8F8F) : null,
                    splashRadius: splashRadius,
                    onPressed: () => _disliked(),
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    splashRadius: splashRadius,
                    onPressed: () {},
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Text(
              "${widget.caption}",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _liked() {
    bool newVal = true;
    if (isLiked) {
      newVal = false;
    } else {
      newVal = true;
      isDisliked = !newVal;
    }
    setState(() {
      isLiked = newVal;
    });
  }

  _disliked() {
    bool newVal = true;
    if (isDisliked) {
      newVal = false;
    } else {
      newVal = true;
      isLiked = !newVal;
    }
    setState(() {
      isDisliked = newVal;
    });
  }

  getUserProfileUrl() async {
    profileUrl = await databaseMethods.getProfileUrl(widget.username);
    setState(() {});
  }
}
