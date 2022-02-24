import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../database/locationDB.dart';
import '../service/locationDB_CRUD.dart' as tracking_system_db;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RecordingButton(),
    );
  }
}

class RecordingButton extends StatefulWidget {
  const RecordingButton({Key? key}) : super(key: key);

  @override
  _RecordingButton createState() => _RecordingButton();
}

class _RecordingButton extends State<RecordingButton>
    with AutomaticKeepAliveClientMixin<RecordingButton> {
  @override
  bool get wantKeepAlive => true;

  var buttonState = true;
  var maxId = 0;
  var stopLoop = false;

  final database = tracking_system_db.openDB();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> storeLocation(Position _currentPosition) async {
    tracking_system_db.getMaxId(database).then((value) {
      maxId = value;
    });

    int simulate = 0; //simulate changing location

    while (!stopLoop) {
      List<UserLocation> locationList = [];
      for (var i = 0; i < 3; i++) {
        simulate += 1;
        locationList.add(UserLocation(
            id: maxId + 1,
            locDateTime: DateTime.now().toString(),
            userLat: _currentPosition.latitude + simulate,
            userLon: _currentPosition.longitude));
        await Future.delayed(Duration(seconds: 1));
        print(locationList);
      }
      tracking_system_db.insertBatchLocation(locationList, database);
    }
  }

  void changeText() {
    if (buttonState == true) {
      // click start recording
      buttonState = false;
      stopLoop = false;
    } else if (buttonState == false) {
      // click stop recording
      buttonState = true;
      stopLoop = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ElevatedButton(
        child: Text(buttonState ? 'start recording' : 'stop recording'),
        onPressed: () {
          setState(() {
            changeText();
          });

          if (buttonState == false) {
            _determinePosition().then((position) {
              storeLocation(position);
              return print(position);
            }).catchError((error) => print(error));
          }
        });
  }
}
