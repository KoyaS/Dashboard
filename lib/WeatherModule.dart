import 'dart:convert';
// import 'dart:html';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final currentLat = "42.280827";
final currentLon = "-83.743034";

class WeatherModule extends StatefulWidget {

  final Function setSunRiseSetTimes;

  WeatherModule({@required this.setSunRiseSetTimes});

  @override
  _WeatherModuleState createState() => _WeatherModuleState();
}

class _WeatherModuleState extends State<WeatherModule> {
  Future<WeatherReport> futureReport;
  Future<Address> address;

  @override
  void initState() {
    futureReport = fetchWeather();
    address = fetchAddress(currentLat, currentLon);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('made IT TO HERE!');
    return FutureBuilder(
      future: Future.wait([futureReport, address]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WeatherReport weatherReport = snapshot.data[0];
          Address address = snapshot.data[1];

          // return(Text(address.city + weatherReport.current['temp'].round().toString()));
          return (WeatherModuleContainer(
              temp: weatherReport.current['temp'].round().toString(),
              location: address.city + ', ' + address.country,
              conditionCode: weatherReport.current['weather'][0]['id']));
        } else {
          return CircularProgressIndicator();
        }
      },
      // (BuildContext context, AsyncSnapshot snapshot) {
      //   print('snapshot data');
      //   print(snapshot.data.toString());
      //   if (snapshot.connectionState == ConnectionState.done) {
      //     print('connection done.');
      //     if (snapshot.hasData) {
      //       print('here');
      //       WeatherReport weatherReport = snapshot.data[0];
      //       String temp = weatherReport.current['temp'].round().toString();
      //       // Address address = snapshot.data[1];
      //       // String location = address.city+ ', ' + address.country;
      //       return WeatherModuleContainer(
      //         temp: temp,
      //         // location: location,
      //       );
      //     } else if (snapshot.hasError) {
      //       return Text("${snapshot.error}");
      //     }
      //   } else {
      //     return Center(child: CircularProgressIndicator());
      //   }
      // },
    );
  }
}

class WeatherModuleContainer extends StatelessWidget {
  final double borderRadius = 10;

  final String temp;
  final String location;
  final int conditionCode;
  
  const WeatherModuleContainer({@required this.temp, @required this.location, @required this.conditionCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(20),
      width: 400,
      height: 400,
      // clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius)),
            child: conditionToImage(conditionCode),
            // new Image.asset('images/sun_clouds.png', width: double.infinity),
          ),
          Spacer(
            flex: 1,
          ),
          Flexible(
            flex: 2,
            child: Text(
              temp + "°",
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 70,
                  fontWeight: FontWeight.w100),
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              location,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 6),
              color: Colors.grey,
              spreadRadius: 2)
        ],
      ),
    );
  }
}

// Find these weather codes here: https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2
// Many weren't included in this chain of conditionals
Image conditionToImage(int condition) {

  if (200<=condition && condition<=232) { // Thunderstorm
    return(new Image.asset('images/weather/rain_lightning.png', width: double.infinity));
  } else if (300<=condition && condition<=321) { // Drizzle
    return(new Image.asset('images/weather/moderate_rain.png', width: double.infinity));
  } else if (500 <= condition && condition <= 531) { // Rain
    return(new Image.asset('images/weather/moderate_rain.png', width: double.infinity));
  } else if (600 <= condition && condition <= 622) { // Snow
    return(new Image.asset('images/weather/snow.png', width: double.infinity));
  } else if (800 == condition) { // Clear
    return(new Image.asset('images/weather/sun_clouds.png', width: double.infinity));
  } else if (801 <= condition && condition <= 804) { // Cloudy
    return(new Image.asset('images/weather/clouds.png', width: double.infinity));
  } else { // Hit em with the sunny day
    return(new Image.asset('images/weather/sun_clouds.png', width: double.infinity));
  }
}

Future<WeatherReport> fetchWeather() async {
  print('Fetching Weather...');
  var response;

  try {
    if (Platform.isAndroid || Platform.isIOS) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      response = await http.get(
          'https://api.openweathermap.org/data/2.5/onecall?lat=${position.latitude.toString()}&lon=${position.longitude.toString()}&exclude=minutely,daily&appid=${DotEnv().env['OPEN_WEATHER_MAP_KEY']}&units=imperial');
    } else {
      throw Exception('Not android or ios');
    }
  } catch (e) {
    response = await http.get(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${currentLat}&lon=${currentLon}&exclude=minutely,daily&appid=${DotEnv().env['OPEN_WEATHER_MAP_KEY']}&units=imperial');
  }

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WeatherReport.fromJSON(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load WeatherReport');
  }
}

Future<Address> fetchAddress(String latitude, String longitude) async {
  print('Fetching Location For Weather...');
  var response = await http.get(
      'https://api.opencagedata.com/geocode/v1/json?q=${latitude}%2C+${longitude}&key=${DotEnv().env['OPEN_CAGE_DATA_KEY']}&pretty=1');
  if (response.statusCode == 200) {
    Address a = Address.fromJSON(json.decode(response.body));
    return a;
  } else {
    throw Exception('Failed to load Address');
  }
}

class WeatherReport {
  final Map<String, dynamic> current;
  final List<dynamic> hourly;

  WeatherReport({this.current, this.hourly});

  factory WeatherReport.fromJSON(Map<String, dynamic> json) {
    return WeatherReport(
      current: json['current'],
      hourly: json['hourly'],
    );
  }

  // DateTime toUseableTime(int unixTime) {
  //   DateTime time = new DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
  //   return time;
  // }
}

class Address {
  final String city;
  final String country;

  Address({this.city, this.country});

  factory Address.fromJSON(Map<String, dynamic> json) {
    List<dynamic> results = json['results'];
    String cty = results[0]['components']['city'].toString();
    String cntry =
        results[0]['components']['country_code'].toString().toUpperCase();
    return Address(
      city: cty,
      country: cntry,
    );
  }
}