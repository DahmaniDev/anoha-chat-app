

import 'package:flutter/material.dart';
import 'package:kelemni/screens/chatscreen.dart';
import 'package:kelemni/services/database.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;


Widget searchListUserTile({String? profileUrl, name, username, email, chatRoomId, myUserName, required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      //var chatRoomId = Home().getChatRoomIdByUserName(myUserName, username);
      Map<String, dynamic> chatRoomInfoMap = {
        "users": [myUserName, username]
      };
      DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(username, name)));
    },
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl!,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              name,
              style: TextStyle(
                  color: AppTheme.isDarkMode
                      ? AppTheme.textDarkModeColor
                      : AppTheme.textLightModeColor),
            ),
            Text(
              email,
              style: TextStyle(
                  color: AppTheme.isDarkMode
                      ? AppTheme.textDarkModeColor
                      : AppTheme.textLightModeColor),
            )
          ])
        ],
      ),
    ),
  );
}