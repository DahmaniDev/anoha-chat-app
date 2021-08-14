

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kelemni/helperfunctions/sharedpref_helper.dart';
import 'package:kelemni/screens/home.dart';
import 'package:kelemni/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods{
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async{
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext ctx) async{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    //Les opérateurs ? sont pour le NULL SAFETY
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken
    );

    UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = userCredential.user;

    if(userCredential != null){
      //Enregistrement des données d'utilisateur dans Firestore
      // L'operateur ! c'est pour attribuer cette valeur seulement si userDetails n'est pas NULL et aussi sa propriété utilisé à chaque fois
      SharedPreferenceHelper().saveUserEmail(userDetails!.email!);
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper()
          .saveUserName(userDetails.email!.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userDetails.displayName!);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL!);


      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email!,
        "username": userDetails.email!.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName!,
        "imgUrl": userDetails.photoURL!
      };

      DatabaseMethods().addUserInfoToDB(userDetails.uid, userInfoMap).then((value) {
        Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await auth.signOut();
  }
}