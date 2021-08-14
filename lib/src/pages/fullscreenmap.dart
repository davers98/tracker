import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class MyLocation extends StatefulWidget {
  @override
  _MyLocationState createState() => _MyLocationState();
}


class _MyLocationState extends State<MyLocation> {
  LocationData _currentPosition;
  String _address,_dateTime;
  GoogleMapController mapController;
  Marker marker;
  Location location = Location();

  final databaseReference = FirebaseDatabase.instance.reference();

  GoogleMapController _controller;
  LatLng _initialcameraposition = LatLng(0.5937, 0.9629);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();


  }

  void _onMapCreated(GoogleMapController _cntlr)
  {
    _controller = _controller;
    location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Container(
            color: Colors.blueGrey.withOpacity(.8),
            child: Center(
              child: Column(
                children: [
                  Container(
                    height:  MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: _initialcameraposition,
                          zoom: 15),
                      mapType: MapType.normal,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  if (_dateTime != null)
                    Text(
                      "Date/Time: $_dateTime",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),

                  SizedBox(
                    height: 3,
                  ),
                  if (_currentPosition != null)
                    Text(
                      "Latitude: ${_currentPosition.latitude}, Longitude: ${_currentPosition.longitude}",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  SizedBox(
                    height: 3,
                  ),
                  if (_address != null)
                    Text(
                      "Address: $_address",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(
                    height: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }


  getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      print("${currentLocation.latitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        _initialcameraposition = LatLng(_currentPosition.latitude,_currentPosition.longitude);
        

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(_currentPosition.latitude, _currentPosition.longitude)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
            
            sendData() {
              FirebaseFirestore.instance.collection('locations')
                  .add({
                  'coordinate': '${_currentPosition.latitude}, ${_currentPosition.longitude}',
                  'time': '${_dateTime}'


              });


            }
            Future<List> sendLoc() async{
              String lat = '${_currentPosition.latitude}';
              String lon = '${_currentPosition.longitude}';
              String url = "http://192.168.87.107/fleet-django/insertdata.php";
              final response = await http.post(Uri.parse('http://192.168.0.101/fleet-django/insertdata.php'), body: {
                "latitude": lat,
                "longitude": lon

              });
              print(lat);
              return json.decode(response.body);

            }
            sendLoc();
            sendData();

          });
        });
      });
    });
  }


  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

}