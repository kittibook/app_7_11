import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Testmap extends StatefulWidget {
  const Testmap({super.key});

  @override
  State<Testmap> createState() => _TestmapState();
}

class _TestmapState extends State<Testmap> {
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
    _addMarkers(); // เรียกใช้ฟังก์ชันเพิ่ม markers
    _addCircles();
    _getCurrentLocation();
    customMarker();
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
    _saveCurrentPosition(); // เรียกใช้ฟังก์ชันบันทึกพิกัดปัจจุบัน
  }

  // ฟังก์ชันคำนวณระยะทาง
  double _calculateDistance(LatLng position) {
    return Geolocator.distanceBetween(
      Seven1.latitude,
      Seven1.longitude,
      position.latitude,
      position.longitude,
    );
  }

  // ฟังก์ชันสำหรับบันทึกพิกัดปัจจุบัน
  void _saveCurrentPosition() {
    setState(() {
      _savedPositions.add(_currentPosition); // เพิ่มพิกัดปัจจุบันลงในลิสต์
      if (_savedPositions.length >= 2) {
        _lastDistance = _calculateDistance(_savedPositions.last);
        print(
            "Distance to last saved position: ${_lastDistance.toStringAsFixed(2)} meters");
      }
    });
  }

  Future<void> _getDirections() async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${Seven1.latitude},${Seven1.longitude}&mode=driving&alternatives=true&key=AIzaSyCKaEyTbcagMAR928sR7-7_hAg29uGdo3M'));

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
      print('Error fetching directions: $e');
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

  // ฟังก์ชันเพิ่ม markers
  void _addMarkers() {
    _markers.add(
      Marker(
        markerId: const MarkerId('Seven1'),
        position: Seven1,
        infoWindow:
            const InfoWindow(title: 'Home', snippet: 'Capital of Thailand'),
        icon: customIcon,
      ),
    );
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

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _latLngDisplay =
          "Lat: ${position.target.latitude}, Lng: ${position.target.longitude}"; // อัปเดตค่าพิกัด
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
        title: const Text('Centered Icon with LatLng Display'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            onCameraMove:
                _onCameraMove, // ฟังก์ชันที่จะเรียกใช้เมื่อกล้องเคลื่อนที่
            onCameraIdle: _onCameraIdle, // ฟังก์ชันเมื่อกล้องหยุดเคลื่อนที่
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 18,
            ),
            myLocationEnabled: true,
            polylines: Set<Polyline>.of(_polylines),
            myLocationButtonEnabled: true,
            markers: _markers,
            circles: _circles,
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
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: () {
                HandleSubmit(); // เรียกใช้ฟังก์ชันเพื่อดึงข้อมูลเส้นทาง
              },
              child: const Text('แสดงเส้นทาง'),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Text(
          //       _latLngDisplay, // แสดงค่าพิกัด
          //       style: const TextStyle(fontSize: 18),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
