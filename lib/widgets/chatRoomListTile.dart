import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kelemni/screens/chatscreen.dart';
import 'package:kelemni/services/database.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  final Timestamp lastTs;
  ChatRoomListTile(
      this.lastMessage, this.chatRoomId, this.myUsername, this.lastTs);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "", email="";
  String formattedTime = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    email = "${querySnapshot.docs[0]["email"]}";
    formattedTime = DateFormat.Hm().format(widget.lastTs.toDate());
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name, profilePicUrl, email)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  profilePicUrl == "" || profilePicUrl == null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/user_icon.png',
                            height: 40,
                            width: 40,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            profilePicUrl,
                            height: 40,
                            width: 40,
                          ),
                        ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.isDarkMode
                                ? Colors.white
                                : AppTheme.buttonLightModeColor),
                      ),
                      SizedBox(height: 3),
                      widget.lastMessage.startsWith('https://firebasestor')
                          ? Row(
                              children: [
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                      color: AppTheme.isDarkMode
                                          ? Colors.white60
                                          : Colors.black),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                      color: AppTheme.isDarkMode
                                          ? Colors.white60
                                          : Colors.black),
                                )
                              ],
                            )
                          : widget.lastMessage.length > 35
                              ? Row(
                                  children: [
                                    Text(
                                      widget.lastMessage.substring(0, 20) +
                                          ' ...',
                                      style: TextStyle(
                                          color: AppTheme.isDarkMode
                                              ? Colors.white60
                                              : Colors.black),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          color: AppTheme.isDarkMode
                                              ? Colors.white60
                                              : Colors.black),
                                    )
                                  ],
                                )
                              : Row(
                                  children: [
                                    Text(
                                      widget.lastMessage,
                                      style: TextStyle(
                                          color: AppTheme.isDarkMode
                                              ? Colors.white60
                                              : Colors.black),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          color: AppTheme.isDarkMode
                                              ? Colors.white60
                                              : Colors.black),
                                    )
                                  ],
                                )
                    ],
                  ),
                  SizedBox(width: 80),
                ],
              ),
            ),
            Divider(
                thickness: 0.8,
                color: AppTheme.isDarkMode
                    ? Colors.white
                    : AppTheme.buttonLightModeColor.withOpacity(0.3))
          ],
        ),
      ),
    );
  }
}
