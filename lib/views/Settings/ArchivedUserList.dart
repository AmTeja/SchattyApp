import 'package:flutter/material.dart';
import 'package:schatty/views/Chatroom/ChatTile.dart';

class ArchivedUserList extends StatefulWidget {
  @override
  _ArchivedUserListState createState() => _ArchivedUserListState();
}

class _ArchivedUserListState extends State<ArchivedUserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Archived Users"),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return ChatRoomTile();
      }),
    );
  }
}
