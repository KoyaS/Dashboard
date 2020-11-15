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
  DateTime sunriseTime;
  DateTime sunsetTime;

  @override
  Widget build(BuildContext context) {
    createBackgroundColors();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.white],
          )),
          width: double.infinity,
          height: double.infinity,
          child: Center(
              child: Wrap(
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

  // BACKGROUND COLOR -------------------------------------------------------------------------------------------------------------------------

  /// This code snippet is from https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Going to aim to change the color once every 15 minutes, 96 total colors
  // Creates an array of 96 values that can be indexed, once for every 15 minutes
  List<Color> createBackgroundColors() {
    sunriseTime = new DateTime.fromMillisecondsSinceEpoch(1605356705 * 1000-18000);
    sunsetTime = new DateTime.fromMillisecondsSinceEpoch(1605392046 * 1000-18000);

    print('sunrise/set time');
    print(sunriseTime);
    print(sunsetTime);

    if (sunriseTime != null) {
      DateTime riseStart = sunriseTime;
      DateTime riseEnd = riseStart.add(new Duration(hours: 1));
      DateTime setStart = sunsetTime;
      DateTime setEnd = setStart.add(new Duration(hours: 1));

      int minuteAtRise = riseStart.hour * 60 + riseStart.minute;
      int minuteAtRiseEnd = riseEnd.hour * 60 + riseEnd.minute;
      int minuteAtSet = setStart.hour * 60 + setStart.minute;
      int minuteAtSetEnd = setEnd.hour * 60 + setEnd.minute;
      int minutesInDay = 24 * 60;

      Color night = fromHex('264653');
      Color skyBlue = fromHex('2a9d8f');
      Color sunset = fromHex('e76f51');

      List<Color> colors = [];

      DateTime now = DateTime.now();
      DateTime lastMidnight = now.subtract(
          Duration(hours: now.hour, minutes: now.minute, seconds: now.second));

      print(minuteAtRise);
      print(minuteAtRiseEnd);
      print(minuteAtSet);
      print(minuteAtSetEnd);

      int numPreSunriseSlots = (minuteAtRise / minutesInDay * 96).round();
      int numSunriseSlots =
          (minuteAtRiseEnd / minutesInDay * 96).round() - numPreSunriseSlots;
      int numDaylightSlots =
          (minuteAtSet / minutesInDay * 96).round() - numSunriseSlots;
      int numSunsetSlots =
          (minuteAtSetEnd / minutesInDay * 96).round() - numDaylightSlots;

      print('bg color generation');
      print(numPreSunriseSlots);
      print(numSunriseSlots);
      print(numDaylightSlots);
      print(numSunsetSlots);

      // CalcInterimPoints('264653', '2a9d8f', n)
    }
  }

  // Calculates what two colors to put into the screens current gradient
  List<Color> selectCurrentColor() {
    DateTime riseStart = sunriseTime;
    DateTime riseEnd = riseStart.add(new Duration(hours: 1));
    DateTime setStart = sunsetTime;
    DateTime setEnd = setStart.add(new Duration(hours: 1));

    DateTime now = new DateTime.now();

    // Color currentColor =
  }

  void setSunRiseSetTimes(DateTime sunrise, DateTime sunset) {
    // if (sunRiseSetTimes != []) { // If this is the first time we've assigned sunrise/set times
    //   setState(() {
    //     sunRiseSetTimes = riseSetTimes;
    //   });
    // } else {
    //   sunRiseSetTimes = riseSetTimes;
    // }

    // setState(() {
    //   sunriseTime =
    //       sunrise; // Try doing this without setstate first, if we can then we can save on refreshing the page when we load
    //   sunsetTime = sunset;
    // });
  }

  /// Takes in two hexadecimal values, x + x0, and a number, n, of interim steps to calculate.
  /// Note that the returned list is n+2. The list includes x and x0.
  List<String> CalcInterimPoints(String x0, String x, int n) {
    List<int> r0 = HexToRGB(x0);
    List<int> x_RGB = HexToRGB(x);

    List<int> v = [
      x_RGB[0] - r0[0],
      x_RGB[1] - r0[1],
      x_RGB[2] - r0[2]
    ]; // Direction vector

    List<int> RGBinterim;
    List<double> interim;
    List<String> HexGradient = [];
    for (int i = 0; i <= n + 1; i++) {
      double t = (1 / (n + 1)) * i;
      interim = [r0[0] + t * v[0], r0[1] + t * v[1], r0[2] + t * v[2]];
      RGBinterim = [interim[0].round(), interim[1].round(), interim[2].round()];
      HexGradient.add(RGBToHex(RGBinterim));
    }

    return HexGradient;
  }

  /// Conversion functions
  /// Note: Limited error handling

  String RGBToHex(List<int> RGB) {
    // Mis-Shapen Data
    if (RGB.length != 3) {
      return null;
    }

    String R = RGB[0].toRadixString(16);
    String G = RGB[1].toRadixString(16);
    String B = RGB[2].toRadixString(16);
    return (R + G + B);
  }

  List<int> HexToRGB(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    // Mis-shapen Data
    // Could also include checks for data between
    if (hex.length != 6) {
      return null;
    }

    int R = int.parse(hex.substring(0, 2), radix: 16);
    int G = int.parse(hex.substring(2, 4), radix: 16);
    int B = int.parse(hex.substring(4, 6), radix: 16);

    return [R, G, B];
  }

  // PROFILE PICTURE ---------------------------------------------------------------------------------------------------------------------------

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
