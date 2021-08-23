import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kelemni/helperfunctions/sharedpref_helper.dart';
import 'package:kelemni/services/database.dart';
import 'package:kelemni/widgets/custom_dialog_box.dart';
import 'package:kelemni/widgets/imageContainer.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;

import '../main.dart';

class ChatScreen extends StatefulWidget {
  //chatWithUsername est le username de l'autre user et name est le displayName de l'autre user
  final String chatWithUsername, name, imgUrl, email;
  //Constructeur
  ChatScreen(this.chatWithUsername, this.name, this.imgUrl, this.email);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

//
class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId;
  late String myName, myProfilPic, myUserName, myEmail;
  Stream messageStream = new StreamController().stream;
  TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  //Récuperer mes données depuis la classe SharedPreferences (Appareil)
  getMyInfoFromSharedPreferences() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilPic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    //Récupération de l'identifiant de chatroom courante
    chatRoomId = getChatRoomIdByUserName(widget.chatWithUsername, myUserName);
  }

  //L'identifiant de la chatroom entre user A et user B est enregistrée comme suit : A_B
  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  //Méthode pour afficher les notifications
  void showNotification() {
    flutterLocalNotificationsPlugin.show(
        0,
        "Avertissement!",
        "Message filtré ! N'est pas accepté par notre part",
        NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                importance: Importance.high,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher')));
  }

  //Méthode d'ajout de message(lorsque l'user clique ser "send"
  addMessage(bool sendClicked, String message, int typeMsg) async {
    if (message != "") {
      //Tester si le message contient une mot à filtrer
      var listOfFilters = await DatabaseMethods().getListOfXwords();
      for (var item in listOfFilters) {
        if (message.contains(item)) {
          var ch = "";
          for (int i = 0; i < item.length; i++) {
            ch += '*';
          }
          message = message.replaceAll(item, ch);
          showNotification();
        }
      }
      //Temps d'envoi du message
      var lastMessageTs = DateTime.now();
      //Données à enregistrer pour ce message
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilPic,
        "type": typeMsg
      };

      //Enregistrer ce message à la base de données
      DatabaseMethods()
          .addMessage(chatRoomId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName
        };
        //Mettre à jour le chatroom(dernier message, temps d'envoi du dernier message...)
        DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          // remove the text in the message input field
          messageController.text = "";
        }
      });
    } else {
      //Si rien n'est écrit et l'utilisateur clique sur "send", un toast est affiché
      Fluttertoast.showToast(
          msg: 'Rien à envoyer',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  //Méthode de récupérer l'image d'après la gallerie de l'appreil et l'appel à la méthode "uploadFile"
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(pickedFile);
    }
  }
  //Enregistrer l'image à la base de données (Firebase Storage)
  Future uploadFile(PickedFile file) async {
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString() + ".jpeg";
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path});
      TaskSnapshot snapshot =
          await reference.putFile(File(file.path), metadata);

      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        addMessage(true, imageUrl, 1);
      });
    } on Exception {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error! Try again!");
    }
  }

  //Widget à afficher si le message est un texte
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
                style: TextStyle(color: Colors.white, fontFamily: 'KleeOne'),
              )),
        ),
      ],
    );
  }

  //Widget de List (Stream) des tous les messages dans une chatroom A_B
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
                  //Si le type de message est égale à 0 on affiche le widget de message Text, sinon on affiche le widget de message image
                  return ds["type"] == 0
                      ? chatMessageTile(
                          ds["message"], myUserName == ds["sendBy"])
                      : imageContainer(context, ds["message"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  //Méthode initialisé à l'ouverture de l'interface Chatscreen pour récupérer le messageStream et l'infos de l'utilisateur connecté
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.person_pin),
              //Consulter profil utilisateur
              onPressed: (){
                showDialog(context: context,
                    builder: (BuildContext context){
                      return CustomDialogBox(
                        title: widget.name,
                        descriptions: '''@${widget.chatWithUsername}
                                      ${widget.email}
                                      ''',
                        text: "OK", img: widget.imgUrl,
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: AppTheme.isDarkMode
            ? Colors.blueGrey.withOpacity(0.5)
            : Colors.white24.withOpacity(0.5),
        child: Stack(
          children: [
            chatMessages(),
            //Bar en bas (TextField, button pour l'image, boutton pour l'envoi
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: AppTheme.isDarkMode
                      ? Colors.blueGrey.withOpacity(0.5)
                      : Colors.white24.withOpacity(0.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      child: Icon(Icons.image,
                          color: AppTheme.appBarLightModeColor),
                      onTap: () {
                        getImage();
                      },
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    // GestureDetector(
                    //   child: Icon(Icons.pin_drop,
                    //       color: AppTheme.appBarLightModeColor),
                    //   onTap: () {},
                    // ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 1.0),
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
                    SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.send,
                        color: AppTheme.appBarLightModeColor,
                      ),
                      onTap: () {
                        addMessage(true, messageController.text, 0);
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
