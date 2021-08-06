import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelemni/helperfunctions/sharedpref_helper.dart';
import 'package:kelemni/services/database.dart';
import 'package:random_string/random_string.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

//
class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId, messageId = "";
  late String myName, myProfilPic, myUserName, myEmail;
  Stream messageStream = new StreamController().stream;
  TextEditingController messageController = TextEditingController();

  getMyInfoFromSharedPreferences() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilPic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    chatRoomId = getChatRoomIdByUserName(widget.chatWithUsername, myUserName);
  }

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageController.text != "") {
      String message = messageController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilPic
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName
        };

        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          // remove the text in the message input field
          messageController.text = "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                ),
                color: sendByMe ? Colors.blue : Colors.black54,
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder<dynamic>(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: AppTheme.appBarLightModeColor,
      ),
      body: Container(
        child: Stack(
          children: [
            Flexible(
                fit: FlexFit.tight,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AppTheme.isDarkMode
                            ? AssetImage("assets/chat-background-2.jpg")
                            : AssetImage("assets/chat-background-1.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.linearToSrgbGamma()),
                  ),
                  child: chatMessages(),
                )),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: AppTheme.isDarkMode ? Colors.blueGrey.withOpacity(0.5) : Colors.white24.withOpacity(0.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                child: Row(
                  children: [
                    SizedBox(width: 8,),
                    GestureDetector(
                      child: Icon(Icons.image, color: AppTheme.appBarLightModeColor),
                      onTap: () {

                      },
                    ),
                    SizedBox(width: 8,),
                    GestureDetector(
                      child: Icon(Icons.pin_drop, color: AppTheme.appBarLightModeColor),
                      onTap: () {

                      },
                    ),
                    SizedBox(width: 8,),
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0,bottom: 1.0),
                          child: TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Ecrivez un message ici ...",
                                ),
                      controller: messageController,
                    ),
                        )),
                    SizedBox(width: 8,),
                    GestureDetector(
                      child: Icon(Icons.send, color: AppTheme.appBarLightModeColor,),
                      onTap: () {
                        addMessage(true);
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
