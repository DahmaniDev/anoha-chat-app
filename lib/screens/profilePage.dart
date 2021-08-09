import 'package:flutter/material.dart';

import 'package:kelemni/Global/Theme.dart' as AppTheme;

class ProfileScreen extends StatelessWidget {
  final String username, displayName, profilPic, email;
  ProfileScreen(this.username, this.displayName, this.profilPic, this.email);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          painter: HeaderCurvedContainer(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '',
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.buttonLightModeColor, width: 5),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: Image.network(
                      profilPic,
                    ).image,
                    fit: BoxFit.fill,
                  )),
            ),
            SizedBox(height: 20),
            Text('@'+username, style: TextStyle(fontFamily: 'Poppins', fontSize: 17, color: AppTheme.isDarkMode ? Colors.white : Colors.black),),
            SizedBox(height: 80,),
            Card(
              shadowColor: AppTheme.isDarkMode ? Colors.blue : AppTheme.appBarLightModeColor,
              elevation: 8,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width/1.5,
                decoration: BoxDecoration(
                  color: AppTheme.isDarkMode ? AppTheme.appBarDarkModeColor.withOpacity(0.9) :AppTheme.buttonLightModeColor.withOpacity(0.8),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Nom : '+ displayName,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ],
        ),
      ],
    );
  }
}

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xff555555);
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 225, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
