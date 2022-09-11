import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location Service Are Disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location Permissions are permanently denaied , we cannot request permissions ');
    }
    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;

    //print('Latitude is ${position!.latitude}');
    // print('Latitude is ${position!.longitude}');
    print('Latitude is ${lat}');
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=54c17ae0d8b4cd54aab3a837ab511ae8";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=54c17ae0d8b4cd54aab3a837ab511ae8";
    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
    print("${weatherResponce.body}");
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  var lat;
  var lon;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: weatherMap==null? Center(child: CircularProgressIndicator(),): SafeArea(
        child: Column(
          children: [
            Text("${DateTime.now()}"),
            Text("${weatherMap!["name"]}"),
            Text("${weatherMap!["main"]["temp"]}"),
            Text("feels_like ${weatherMap!["main"]["feels_like"]}"),
          ],
        ),
      ),
    );
  }
}
