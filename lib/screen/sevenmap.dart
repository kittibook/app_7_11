import 'package:app_7_11/app_router.dart';
import 'package:app_7_11/utility.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Sevenmap extends StatefulWidget {
  const Sevenmap({super.key});

  @override
  State<Sevenmap> createState() => _SevenmapState();
}

class _SevenmapState extends State<Sevenmap> {
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

  // หมุด seven
  // ignore: non_constant_identifier_names
  LatLng Seven1 = const LatLng(19.029770588431973, 99.926240667770077);
  final Set<Circle> _circles = {};
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ฟังก์ชันเพิ่ม markers
  // void _addMarkers() {
  //   _markers.add(
  //     Marker(
  //       markerId: const MarkerId('Seven1'),
  //       position: Seven1,
  //       infoWindow:
  //           const InfoWindow(title: 'Home', snippet: 'Capital of Thailand'),
  //       icon: customIcon,
  //     ),
  //   );
  // }
// ฟังก์ชันสำหรับสร้าง custom marker
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
    print(_currentPosition);

    // เพิ่ม Marker ลงใน _markers

    await Utility.setSharedPreference('SEVEN1', _currentPosition.latitude);
    await Utility.setSharedPreference('SEVEN2', _currentPosition.longitude);

    setState(() {
      _savedPositions.add(_currentPosition); // เพิ่มพิกัดปัจจุบันลงในลิสต์
      _markers.add(
        Marker(
          markerId: const MarkerId('SEVEN!'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'SEVEN!', snippet: 'ME!'),
          icon: customIcon, // ใช้ customIcon ที่โหลดมา
        ),
      );
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
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(6, 130, 68, 1),
        title: const Text(
          "ตั้งค่าที่ตั้ง 7-11",
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
                zoom: 18,
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
              child: Image.asset(
                'assets/images/custom_marker.png',
                scale: 5.0,
              )),
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
                        Navigator.pushReplacementNamed(context, AppRouter.usersevenmap);
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
