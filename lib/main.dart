import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps for Dartup',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Set<Marker> _markers = {};
  //Set<Polygon> _poly = {};
  final Geolocator _geolocator = Geolocator()..forceAndroidLocationManager;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    setState(() {
    loadMarkers();
        });
    _getCurrent();
  }

  static final CameraPosition _spb = CameraPosition(
    target: LatLng(59.9569769, 30.3083067),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
      initialCameraPosition: _spb,
      markers: Set.from(_markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },

    ),);
  }

  Future<void> _getCurrent() async {
    _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      )));
    }).catchError((e) {
      print(e);
    });
  }

  Future loadMarkers() async {
    var jsonData = await rootBundle.loadString('assets/points.json');
    var data = json.decode(jsonData);

    data["coords"].forEach((item) {
      _markers.add(new Marker(
          markerId: MarkerId(item["ID"]),
          position: LatLng(
              double.parse(item["latitude"]), double.parse(item["longitude"])),
          infoWindow: InfoWindow(
            title: item["comment"],
          ),
          //icon: BitmapDescriptor.defaultMarkerWithHue(
          //   BitmapDescriptor.hueGreen)));
          icon: BitmapDescriptor.defaultMarker));
    });
  }

}
