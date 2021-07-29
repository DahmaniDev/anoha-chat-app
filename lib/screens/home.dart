import 'package:flutter/material.dart';
import 'package:kelemni/screens/signin.dart';
import 'package:kelemni/services/auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kelemni'),
          backgroundColor: Color(0xFF8a2c02),
          actions: [
            InkWell(
              onTap: () {
                AuthMethods().signOut().then((s) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
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
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.05),
                child: Row(
                  children: [
                    const Expanded(
                        child: TextField(
                            decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                hintText: 'Chercher un utilisateur'))),
                    IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Color(0xFF8a2c02),))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
