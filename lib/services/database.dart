import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kelemni/helperfunctions/sharedpref_helper.dart';

class DatabaseMethods {
  Future addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  //Méthode appelé lors de la recherche d'un utilisateur
  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: username)
        .where("username", isLessThanOrEqualTo: username + '~')
        .snapshots();
  }

  //Méthode appelé lors de l'ajout d'un message
  Future addMessage(String chatRoomId, Map<String,dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc()
        .set(messageInfoMap);
  }

  //Méthode appelé lors de l'ajout d'un message pour faire le mis à jour de chatroom
  updateLastMessageSend(String chatRoomId, Map<String,dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  //Méthode appelé lors de la clique sur un utilisateur parmi la liste de la recherche
  createChatRoom(String chatRoomId, Map<String,dynamic> chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  //Méthode appelé lors de l'ouverture de l'interface ChatScreen d'une chatroom
  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }
  //Méthode appelé lors de l'ouverture de l'interface Home (Chatrooms)
  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }
  //Méthode appelé lors de l'ouverture de AlertBox de consultation Profil
  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }
  //Méthode appelé pour la récupération des mots à filtrer
  Future<List<String>> getListOfXwords() async {
    var items = await FirebaseFirestore.instance.collection("filtres").get();
    List<String> list =
    items.docs.map((doc) => doc.data()['msgFiltre'].toString()).toList();
    return list;
  }

}