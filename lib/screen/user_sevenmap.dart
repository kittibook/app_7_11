import 'dart:convert';

import 'package:app_7_11/utility.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class UserSevenmap extends StatefulWidget {
  const UserSevenmap({super.key});

  @override
  State<UserSevenmap> createState() => _UserSevenmapState();
}

class _UserSevenmapState extends State<UserSevenmap> {
  late GoogleMapController mapController;
  LatLng _currentPosition =
      const LatLng(19.029770588431973, 99.926240667770077);
  String _latLngDisplay = ""; // สำหรับแสดงค่า Latitude และ Longitude
  double _iconOffsetY = 0; // สำหรับการเลื่อนไอคอน
  final Set<Marker> _markers = {};
  Map<MarkerId, Marker> markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _savedPositions = []; // สำหรับเก็บพิกัดที่บันทึก
  double _lastDistance = 0; // สำหรับเก็บระยะทางล่าสุด
  double _shippingCost = 0.0;
  LatLng user = LatLng(0, 0);
  // หมุด seven
  AssetMapBitmap SevenIcon = AssetMapBitmap(
    'assets/images/custom_marker.png',
    width: 25,
    height: 25,
  );
  // ignore: non_constant_identifier_names
  LatLng Seven1 = LatLng(0, 0);
  final Set<Circle> _circles = {};
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getdata();
    // _addMarkers(); // เรียกใช้ฟังก์ชันเพิ่ม markers
    customMarker();
  }

  Future<void> getdata() async {
    var user1 = await Utility.getSharedPreference('USERMARKER1');
    var user2 = await Utility.getSharedPreference('USERMARKER2');
    var map1 = await Utility.getSharedPreference('SEVEN1');
    var map2 = await Utility.getSharedPreference('SEVEN2');
    setState(() {
      if (user1 != null && user2 != null) {
        _currentPosition = LatLng(user1, user2);
      }
      if (map1 != null && map2 != null) {
        Seven1 = LatLng(map1, map2);
      }

      _markers.add(
        Marker(
          markerId: const MarkerId('Seven1'),
          position: Seven1,
          infoWindow:
              const InfoWindow(title: 'Seven', snippet: 'Seven of Thailand'),
          icon: SevenIcon,
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('User'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
    HandleSubmit();
  }

  // ฟังก์ชันสำหรับเพิ่มวงกลมรอบๆ marker
  void _addCircles() {
    _circles.add(Circle(
      circleId: CircleId('Seven'),
      center: Seven1,
      radius: 3000, // ตั้งค่ารัศมีเป็น 1000 เมตร (สามารถปรับเปลี่ยนได้)
      fillColor: Colors.blue.withOpacity(0.2), // สีที่เติมภายใน
      strokeColor: Colors.blue, // สีขอบ
      strokeWidth: 2, // ความหนาของขอบ
    ));
  }

  void HandleSubmit() {
    _getDirections(); // เรียกใช้ฟังก์ชันเพื่อวาดเส้นทาง
    _addCircles();
    _saveCurrentPosition(); // เรียกใช้ฟังก์ชันบันทึกพิกัดปัจจุบัน
  }

  // ฟังก์ชันคำนวณระยะทาง
  double _calculateDistance() {
    return Geolocator.distanceBetween(
      Seven1.latitude,
      Seven1.longitude,
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
  }

  // ฟังก์ชันสำหรับบันทึกพิกัดปัจจุบัน
  void _saveCurrentPosition() {
    setState(() {
      _savedPositions.add(_currentPosition);
      _lastDistance = _calculateDistance();
      _checkDistanceForShipping();
    });
  }

  void _checkDistanceForShipping() {
    if (_lastDistance <= 3000) {
      setState(() {
        _shippingCost = 0;
      });
    } else {
      double additionalCost = (_lastDistance - 3000) *
          0.05; // คิดค่าบริการ 0.05 ต่อเมตรหลังจาก 3 กิโลเมตร
      setState(() {
        _shippingCost = additionalCost;
      });
    }
  }

  Future<void> _getDirections() async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${Seven1.latitude},${Seven1.longitude}&destination=${_currentPosition.latitude},${_currentPosition.longitude}&mode=driving&alternatives=true&key=AIzaSyDdlrYf7eKH5CyMlnpP09HCDVSK7JOCzAg'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final polyline = routes[0]['overview_polyline']['points'];
          _addPolyline(polyline);
        }
      } else {
        throw Exception('Failed to load directions');
      }
    } catch (e) {
    }
  }

  void _addPolyline(String polyline) {
    final points = _decodePolyline(polyline);
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void customMarker() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(
          size: Size(48, 48)), // สามารถปรับขนาดได้ตามต้องการ
      'assets/images/custom_marker.png',
    ).then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  // ignore: unused_element
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try to request permissions again
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted, and we can access the position.
    Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _latLngDisplay =
          "Lat: ${position.latitude}, Lng: ${position.longitude}"; // แสดงค่าเริ่มต้น
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  void _onCameraIdle() {
    // กลับไอคอนลงมาที่ตำแหน่งเดิมเมื่อกล้องหยุดเคลื่อนที่
    setState(() {
      _iconOffsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 130, 68, 1),
        title: const Text(
          "ระยะห่าง",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height -
                100, // ความสูงของ GoogleMap (ลดจากความสูงทั้งหมด)
            child: GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              onCameraIdle: _onCameraIdle,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 18,
              ),
              myLocationEnabled: true,
              polylines: Set<Polyline>.of(_polylines),
              myLocationButtonEnabled: true,
              circles: _circles,
              markers: _markers,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0, // กำหนดให้กล่องสีเขียวขยายเต็มพื้นที่
            child: Container(
              color: Color.fromRGBO(255, 255, 255, 1), // สีพื้นหลัง
              height:
                  MediaQuery.of(context).size.height * 0.12, // ความสูงของกล่อง
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: GestureDetector(
                      onTap: () async {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                              'ราคาค่าส่ง : ${_shippingCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(0, 134, 89, 1))),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
