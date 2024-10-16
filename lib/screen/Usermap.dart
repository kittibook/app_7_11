import 'dart:convert';

import 'package:app_7_11/app_router.dart';
import 'package:app_7_11/utility.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Usermap extends StatefulWidget {
  const Usermap({super.key});

  @override
  State<Usermap> createState() => _UsermapState();
}

class _UsermapState extends State<Usermap> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  LatLng _currentUserPosition = const LatLng(0, 0);
  double _iconOffsetY = 0; // สำหรับการเลื่อนไอคอน
  final Set<Marker> _markers = {};
  Map<MarkerId, Marker> markers = {};
  final List<LatLng> _savedPositions = []; // สำหรับเก็บพิกัดที่บันทึก
  // หมุด seven
  // ignore: non_constant_identifier_names
  LatLng Seven1 = const LatLng(0, 0);
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getdata();
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
      mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    });
  }


  Future<void> _getAddressFromLatLng() async {
    const apiKey =
        'AIzaSyDdlrYf7eKH5CyMlnpP09HCDVSK7JOCzAg'; // เปลี่ยนเป็น API Key ของคุณ
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_currentPosition.latitude},${_currentPosition.longitude}&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        await Utility.setSharedPreference(
            'USERMARKER', data['results'][0]['formatted_address']);
      } else {}
    } else {}
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;

      _iconOffsetY = 15; // ย้ายไอคอนขึ้นน้อยลง
    });
  }

  void _onCameraIdle() {
    // กลับไอคอนลงมาที่ตำแหน่งเดิมเมื่อกล้องหยุดเคลื่อนที่
    setState(() {
      _iconOffsetY = 0;
    });
  }

  void customMarker() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), // ขนาดของไอคอน
      'assets/images/custom_marker.png', // พาธของไฟล์ภาพ
    ).then((icon) {
      setState(() {
        customIcon = icon; // เก็บไอคอนลงในตัวแปร customIcon
      });
    });
  }

// ฟังก์ชันสำหรับบันทึกพิกัดปัจจุบัน
  Future<void> _saveCurrentPosition() async {
    // เพิ่ม Marker ลงใน _markers

    await Utility.setSharedPreference('USERMARKER1', _currentPosition.latitude);
    await Utility.setSharedPreference('USERMARKER2', _currentPosition.longitude);

    setState(() {
      _savedPositions.add(_currentPosition); // เพิ่มพิกัดปัจจุบันลงในลิสต์
      _getAddressFromLatLng();
      getdata();
    });
  }

  AssetMapBitmap SevenIcon = AssetMapBitmap(
    'assets/images/custom_marker.png',
    width: 25,
    height: 25,
  );

  Future<void> getdata() async {
    var user1 = await Utility.getSharedPreference('USERMARKER1');
    var user2 = await Utility.getSharedPreference('USERMARKER2');
    var map1 = await Utility.getSharedPreference('SEVEN1');
    var map2 = await Utility.getSharedPreference('SEVEN2');


    setState(() {
      if (user1 != null && user2 != null) {
        _currentUserPosition = LatLng(user1, user2);
      }
      if (map1 != null && map2 != null) {
        Seven1 = LatLng(map1, map2);
      }


      _markers.clear();
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
          position: _currentUserPosition,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: customIcon,
        ),
      );
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 130, 68, 1),
        title: const Text(
          "ปักหมุดบนแผนที่",
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
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 10,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 -
                70 -
                _iconOffsetY, // คำนวณตำแหน่งแนวตั้งของไอคอน
            left: MediaQuery.of(context).size.width / 2 -
                12.5, // ตำแหน่งแนวนอนของไอคอน
            child: const Icon(
              Icons.location_on,
              size: 25, // ขนาดของไอคอน
              color: Color.fromARGB(255, 219, 50, 38), // สีของไอคอน
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 -
                50, // ตำแหน่งแนวตั้งของเงา
            left: MediaQuery.of(context).size.width / 2 -
                5, // ตำแหน่งแนวนอนของเงา
            child: Container(
              width: 10, // ขนาดของเงา (ความกว้าง)
              height: 10, // ขนาดของเงา (ความสูง)
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // สีของเงา
                borderRadius: BorderRadius.circular(15), // ทำให้เป็นวงรี
              ),
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
                      onTap: () async {
                        _saveCurrentPosition();
                        Navigator.pushReplacementNamed(context, AppRouter.shoppingcart);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromRGBO(6, 130, 68, 1),
                        ),
                        child: Center(
                          child: Text('บันทึก',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(255, 255, 255, 1))),
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
