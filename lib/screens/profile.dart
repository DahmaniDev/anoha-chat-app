import 'package:flutter/material.dart';
import 'package:kelemni/Global/Theme.dart' as AppTheme;

class ProfilePage extends StatelessWidget {
  final String username, displayName, profilPic, email;
  ProfilePage(this.username,this.displayName,this.profilPic,this.email);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profilPic,
                height: 90,
                width: 90,
              ),
            ),
            SizedBox(height: 30),
            Text(displayName,style: TextStyle(
                color: AppTheme.isDarkMode
                    ? AppTheme.textDarkModeColor
                    : AppTheme.textLightModeColor),),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Username:',style: TextStyle(
                    color: AppTheme.isDarkMode
                        ? AppTheme.textDarkModeColor
                        : AppTheme.textLightModeColor)),
                Text(username,style: TextStyle(
                    color: AppTheme.isDarkMode
                        ? AppTheme.textDarkModeColor
                        : AppTheme.textLightModeColor))
              ],
            ),
            SizedBox(height: 30),
            Text(email,style: TextStyle(
                color: AppTheme.isDarkMode
                    ? AppTheme.textDarkModeColor
                    : AppTheme.textLightModeColor))
          ],
        ),
      ),
    );
  }
}
