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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Wrap(
        // children: [ClockModule(), NewsModule(), WeatherModule(),],
        children: [
          // ToDoModule(client: authClient),
          // EmailModule(gmailApi: gmailApi),
          ClockModule(), 
          NewsModule(), 
          WeatherModule(),
        ],
        //
      ),
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
