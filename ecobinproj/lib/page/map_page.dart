import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  final String result; // 전달받은 쓰레기 유형

  const MapPage({Key? key, required this.result}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LocationData? _currentPosition;
  final Location _location = Location();

  List<Map<String, dynamic>> trashBins = [];
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> nearestBins = [];
  Map<String, dynamic>? selectedBin;
  bool binSelected = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await _location.getLocation();
  }

  Future<void> _loadTrashBinData() async {
    final String response = await rootBundle.loadString('assets/trash_bins.json');
    final data = json.decode(response);
    setState(() {
      trashBins = List<Map<String, dynamic>>.from(data);
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371e3; // meters
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLon = _degreesToRadians(end.longitude - start.longitude);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _showNearestTrashBins() async {
    if (_currentPosition == null) return; // 위치 정보가 없으면 반환

    LatLng currentLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
    List<Map<String, dynamic>> filteredBins = trashBins.where((bin) {
      return bin['type'].contains(widget.result); // 쓰레기 유형 필터링
    }).toList();

    filteredBins.sort((a, b) {
      final LatLng locationA = LatLng(a['coordinate']['latitude'], a['coordinate']['longitude']);
      final LatLng locationB = LatLng(b['coordinate']['latitude'], b['coordinate']['longitude']);
      final double distanceA = _calculateDistance(currentLocation, locationA);
      final double distanceB = _calculateDistance(currentLocation, locationB);
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      nearestBins = filteredBins.take(5).toList();
      _markers.clear();
      selectedBin = null;
      binSelected = false;
      for (var bin in nearestBins) {
        _markers.add(
          Marker(
            markerId: MarkerId(bin['address']),
            position: LatLng(bin['coordinate']['latitude'], bin['coordinate']['longitude']),
            infoWindow: InfoWindow(
              title: bin['location'],
              snippet: bin['type'].join(', '),
            ),
          ),
        );
      }
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation, 13.0),
    );
  }

  void _selectBin(Map<String, dynamic> bin) {
    setState(() {
      selectedBin = bin;
      binSelected = true;
    });
  }

  void _confirmSelection() {
    setState(() {
      _markers.clear();
      nearestBins = [selectedBin!]; // 선택된 빈만 남김
      _markers.add(
        Marker(
          markerId: MarkerId(selectedBin!['address']),
          position: LatLng(selectedBin!['coordinate']['latitude'], selectedBin!['coordinate']['longitude']),
          infoWindow: InfoWindow(
            title: selectedBin!['location'],
            snippet: selectedBin!['type'].join(', '),
          ),
        ),
      );
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(selectedBin!['coordinate']['latitude'], selectedBin!['coordinate']['longitude']),
          15.0,
        ),
      );
      binSelected = false; // 선택된 후 선택 상태 초기화
    });
  }

  void _resetSelection() {
    setState(() {
      selectedBin = null;
      nearestBins.clear();
      _markers.clear();
      binSelected = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _location.requestPermission().then((_) async {
      await _getCurrentLocation(); // 현재 위치 가져오기
      await _loadTrashBinData(); // JSON 데이터 로드
      await _showNearestTrashBins(); // 근처 쓰레기통 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.5665, 126.9780), // 초기 지도 위치 (서울 시청)
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
          ),
          if (nearestBins.isNotEmpty && !binSelected)
            Container(
              height: 200,
              color: Colors.white,
              child: ListView.builder(
                itemCount: nearestBins.length,
                itemBuilder: (context, index) {
                  final bin = nearestBins[index];
                  return ListTile(
                    title: Text(bin['location']),
                    subtitle: Text(bin['address']),
                    onTap: () => _selectBin(bin),
                  );
                },
              ),
            ),
          if (binSelected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _confirmSelection,
                child: const Text('선택하기'),
              ),
            ),
          if (selectedBin != null && !binSelected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _resetSelection,
                    child: const Text('포기하기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('완료되었습니다!')),
                      );
                      // 완료 기능을 여기에 추가하세요.
                    },
                    child: const Text('완료하기'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
