import 'package:Dashboard/ClockModule.dart';
import 'package:Dashboard/EmailModule.dart';
import 'package:Dashboard/ToDoModule.dart';
import 'package:Dashboard/WeatherModule.dart';
import 'package:Dashboard/NewsModule.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'googleAuth.dart' as gAuth;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_browser.dart' as auth;

class TodaysView extends StatefulWidget {
  @override
  _TodaysViewState createState() => _TodaysViewState();
}

class _TodaysViewState extends State<TodaysView> {
  gmail.GmailApi gmailApi;
  auth.AutoRefreshingAuthClient authClient;
  String profileDataString;
  List<DateTime> sunRiseSetTimes = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: calculateBackgroundColors(),
            )
        ),
        width: double.infinity,
        height: double.infinity,
          child: Center(child:Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        // children: [ClockModule(), NewsModule(), WeatherModule(),],
        children: [
          // ToDoModule(client: authClient),
          // EmailModule(gmailApi: gmailApi),
          ClockModule(),
          NewsModule(),
          WeatherModule(setSunRiseSetTimes: setSunRiseSetTimes),
        ],
        //
      ))),
      floatingActionButton: () {
        if (gmailApi == null) {
          return (Container(
            margin: EdgeInsets.only(top: 100),
            // height: 50,
            // width: 50,
            child: IconButton(
              iconSize: 50,
              icon: Icon(Icons.account_circle),
              onPressed: () async {
                List temp = await gAuth.showSignInPopup(context);
                setState(() {
                  // gmailApi = temp;
                  // print(temp);
                  gmailApi = temp[0];
                  authClient = temp[1];
                  // profileDataString = temp[2];
                });
              },
            ),
          ));
        } else {
          return (ProfilePictureButton(
            profilePicGetter: getProfilePicture(),
          ));
        }
      }(),
    );
  }

  /// This code snippet is from https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  List<Color> calculateBackgroundColors() {

  }

  void setSunRiseSetTimes(List<DateTime> riseSetTimes) {
    // if (sunRiseSetTimes != []) { // If this is the first time we've assigned sunrise/set times
    //   setState(() {
    //     sunRiseSetTimes = riseSetTimes;
    //   });
    // } else {
    //   sunRiseSetTimes = riseSetTimes;
    // }
    sunRiseSetTimes = riseSetTimes; // Try doing this without setstate first, if we can then we can save on refreshing the page when we load
  }

  Future<String> getProfilePicture() async {
    print('getting photo...');
    var profile = await authClient
        .get('https://people.googleapis.com/v1/people/me?personFields=photos');
    // print('profile photo');
    // print(profile.body);
    Map<String, dynamic> parsed = json.decode(profile.body);
    Map<String, dynamic> photoInfo = parsed['photos'][0];
    String url = photoInfo['url'];
    return (url);
  }
}

class ProfilePictureButton extends StatelessWidget {
  final Future<String> profilePicGetter;

  ProfilePictureButton({this.profilePicGetter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: profilePicGetter,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return (Text('none'));
          case ConnectionState.waiting:
            return (CircularProgressIndicator());
          case ConnectionState.active:
            return (Text('active'));
          case ConnectionState.done:
            if (snapshot.data != null) {
              return Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(top: 100),
                  child: Center(
                    child: InkWell(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        snapshot.data,
                        fit: BoxFit.cover,
                      ),
                    )
                        // onTap: ,
                        ),
                  ));

              // Image.network(snapshot.data);
            } else {
              return (Text('hi'));
            }
            return (Text('This is a required filler for switch block'));
          default:
            return (Text('default'));
        }
      },
    );
  }
}
