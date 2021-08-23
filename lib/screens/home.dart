import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:kelemni/helperfunctions/sharedpref_helper.dart';
import 'package:kelemni/screens/profilePage.dart';
import 'package:kelemni/screens/signin.dart';
import 'package:kelemni/services/auth.dart';
import 'package:kelemni/services/database.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;
import 'package:kelemni/widgets/chatRoomListTile.dart';
import 'package:kelemni/widgets/searchListUserTile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  int _currentIndex = 0;
  late Stream usersStream;
  Stream chatRoomsStream = new StreamController().stream;
  String myName = "", myProfilePic = "", myUserName = "", myEmail = "";
  TextEditingController searchController = TextEditingController();

  @override
  initState() {
    AppTheme.isDarkMode = false;
    super.initState();
    onScreenLoaded();
  }

  //Récupération de données d'utilisateur connecté et récupération des chatrooms
  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  //Récupération de données d'utilisateur connecté
  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
    setState(() {});
  }

  //L'identifiant de la chatroom entre user A et user B est enregistrée comme suit : A_B
  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
  //Widget de List (Stream) des tous les chatrooms de l'utilisateur connecté
  Widget chatRoomsList() {
    return StreamBuilder<dynamic>(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName,
                      ds["lastMessageSendTs"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  //Méthode à éxecuter lorsque l'utilisateur clique sur le boutton "chercher"
  onSearchBtnClick() async {
    //Récupérer les utilisateurs qui leurs usernames correspond à le texte écrit à la barre de recherche
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchController.text.toLowerCase());

    setState(() {});
  }
  //Widget de List (Stream) des utilisateurs récupérés par la méthode de recherche
  Widget searchUsersList() {
    return StreamBuilder<dynamic>(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"],
                      chatRoomId:
                          getChatRoomIdByUserName(myUserName, ds["username"]),
                      myUserName: myUserName,
                      context: context);
                },
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFe32b4a),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelemni',
          style: TextStyle(fontFamily: 'KaushanScript', fontSize: 28),
        ),
        backgroundColor: AppTheme.appBarLightModeColor,
        elevation: 8.0,
        actions: [
          //Button de changement de Mode (DarkMode / LightMode)
          IconButton(
            icon: AppTheme.isDarkMode
                ? Icon(Icons.wb_sunny)
                : Icon(Icons.nightlight_round),
            onPressed: () {
              setState(() {
                AppTheme.isDarkMode = !AppTheme.isDarkMode;
              });
            },
          ),
          //Button de Logout
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app_rounded),
            ),
          )
        ],
      ),
      body: Container(
        color: AppTheme.isDarkMode
            ? AppTheme.backgroundDarkModeColor
            : AppTheme.backgroundLightModeColor,
        height: MediaQuery.of(context).size.height,
        //si currentIndex == 0 alors on affiche l'interface de recherche
        child: _currentIndex == 0
            ? Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.05,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Row(
                      children: [
                        isSearching
                            ? Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: AppTheme.isDarkMode
                                          ? AppTheme.buttonDarkModeColor
                                          : AppTheme.buttonLightModeColor),
                                  onPressed: () {
                                    setState(() {
                                      isSearching = false;
                                      searchController.text = "";
                                    });
                                  },
                                ),
                              )
                            : Container(),
                        Expanded(
                            child: TextField(
                                onChanged: (value) {
                                  if (value == "") {
                                    isSearching = false;
                                  } else {
                                    setState(() {
                                      isSearching = true;
                                    });
                                    onSearchBtnClick();
                                  }
                                },
                                style: TextStyle(
                                    color: AppTheme.isDarkMode
                                        ? AppTheme.textDarkModeColor
                                        : AppTheme.textLightModeColor),
                                controller: searchController,
                                decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    hintStyle: TextStyle(
                                        color: AppTheme.isDarkMode
                                            ? AppTheme.textDarkModeColor
                                            : AppTheme.textLightModeColor),
                                    hintText: 'Chercher un utilisateur'))),
                        IconButton(
                            onPressed: () {
                              if (searchController.text != "") {
                                setState(() {
                                  isSearching = true;
                                });
                                onSearchBtnClick();
                              }
                            },
                            icon: Icon(
                              Icons.search,
                              color: AppTheme.isDarkMode
                                  ? AppTheme.buttonDarkModeColor
                                  : AppTheme.buttonLightModeColor,
                            ))
                      ],
                    ),
                  ),
                  isSearching
                      ? searchUsersList()
                      : Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 50,),
                              Center(
                                child: Image.asset(
                                  'assets/search.png',
                                  height: 160,
                                ),
                              ),
                            ],
                          ),
                      ),
                  //
                ],
              )
        //si currentIndex == 1 alors on affiche l'interface de chatrooms
            : _currentIndex == 1
                ? Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: chatRoomsList(),
                    ),
                  )
        //si currentIndex == 2 alors on affiche l'interface de profil
                : _currentIndex == 2
                    ? ProfileScreen(myUserName, myName, myProfilePic, myEmail)
                    : Container(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        elevation: 5.0,
        type: BottomNavigationBarType.shifting,
        items: [
          //292828
          BottomNavigationBarItem(
              icon: Icon(Icons.search, color: AppTheme.appBarLightModeColor),
              //label: 'Recherche',
              title: Text('Recherche',
                  style: TextStyle(color: AppTheme.appBarLightModeColor)),
              backgroundColor:
                  AppTheme.isDarkMode ? Color(0xFF292828) : Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: AppTheme.appBarLightModeColor),
              //label: 'Chat',
              title: Text('Chat',
                  style: TextStyle(color: AppTheme.appBarLightModeColor)),
              backgroundColor:
                  AppTheme.isDarkMode ? Color(0xFF292828) : Colors.white),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: AppTheme.appBarLightModeColor,
              ),
              title: Text('Profil',
                  style: TextStyle(color: AppTheme.appBarLightModeColor)),
              backgroundColor:
                  AppTheme.isDarkMode ? Color(0xFF292828) : Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
