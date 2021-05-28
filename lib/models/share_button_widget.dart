import 'package:flutter/material.dart';

class ShareButtonWidget extends StatelessWidget {
  final VoidCallback onClicked;

  const ShareButtonWidget({
    Key key,
    @required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      IconButton(icon: Icon(Icons.share), iconSize: 25, onPressed: onClicked);
}
