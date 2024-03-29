import 'package:flutter/material.dart';

class MessageNotification extends StatelessWidget {
  final VoidCallback onReply;
  final title;
  final body;

  const MessageNotification({Key key, this.onReply, this.title, this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          title: Text('$title'),
          subtitle: Text('$body'),
          trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                ///TODO i'm not sure it should be use this widget' BuildContext to create a Dialog
                ///maybe i will give the answer in the future
                if (onReply != null) onReply();
              }),
        ),
      ),
    );
  }
}
