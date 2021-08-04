import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kelemni/helperfunctions/sharedpref_helper.dart';
import 'package:kelemni/screens/chatscreen.dart';
import 'package:kelemni/screens/profile.dart';
import 'package:kelemni/screens/signin.dart';
import 'package:kelemni/services/auth.dart';
import 'package:kelemni/services/database.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  bool isLoading = true;
  int _currentIndex = 0;
  late Stream usersStream, chatRoomsStream;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController searchController = TextEditingController();

  @override
  initState() {
    AppTheme.isDarkMode = false;
    super.initState();
    onScreenLoaded().whenComplete(() {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
    setState(() {});
  }

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

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
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Image.asset(
                              'assets/notfound.png',
                              height: 160,
                            ),
                          )
                        ]),
                  );
      },
    );
  }

  onSearchBtnClick() async {
    usersStream =
        await DatabaseMethods().getUserByUserName(searchController.text);

    setState(() {});
  }

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
                      username: ds["username"]);
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

  Widget searchListUserTile({String? profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUserName(myUserName, username);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelemni',
          style: TextStyle(fontFamily: 'KaushanScript', fontSize: 28),
        ),
        backgroundColor: AppTheme.isDarkMode
            ? AppTheme.appBarDarkModeColor
            : AppTheme.appBarLightModeColor,
        elevation: 8.0,
        actions: [
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
                                          : AppTheme
                                              .buttonLightModeColor),
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
                                            : AppTheme
                                                .textLightModeColor),
                                    //fillColor: isDarkMode ? AppTheme.Theme.buttonDarkModeColor : AppTheme.Theme.buttonLightModeColor,
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
                  isSearching ? searchUsersList() : Container()
                  //
                ],
              )
            : _currentIndex == 1
                ? Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: chatRoomsList(),
                    ),
                  )
                : _currentIndex == 2
                    ? ProfilePage(myUserName, myName, myProfilePic, myEmail)
                    : Container(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        elevation: 5.0,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Recherche',
              backgroundColor: AppTheme.buttonLightModeColor),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
              backgroundColor: AppTheme.buttonLightModeColor),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
              backgroundColor: AppTheme.buttonLightModeColor)
        ],
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
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
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
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
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 3),
                    Text(widget.lastMessage)
                  ],
                ),
                SizedBox(width: 80),
              ],
            ),
            Divider(
                thickness: 0.8,
                color: AppTheme.buttonLightModeColor.withOpacity(0.3))
          ],
        ),
      ),
    );
  }
}
