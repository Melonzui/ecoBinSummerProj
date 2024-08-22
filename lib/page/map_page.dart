import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  final String result;

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
  int? expandedIndex; // 확장된 카드의 인덱스를 추적

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await _location.getLocation();
  }

  Future<void> _completeTask() async {
    if (_currentPosition == null || selectedBin == null) return;

    LatLng currentLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
    LatLng binLocation =
        LatLng(selectedBin!['coordinate']['latitude'], selectedBin!['coordinate']['longitude']);
    double distance = _calculateDistance(currentLocation, binLocation);

    double threshold = 0.0001;

    if (distance <= threshold) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('성공'),
            content: Text('쓰레기통에 성공적으로 접근했습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('실패'),
            content: Text('쓰레기통에 더 가까이 가야 합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadTrashBinData() async {
    final String response = await rootBundle.loadString('assets/trash_bins.json');
    final data = json.decode(response);
    setState(() {
      trashBins = List<Map<String, dynamic>>.from(data);
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    final double dLat = start.latitude - end.latitude;
    final double dLon = start.longitude - end.longitude;
    return dLat * dLat + dLon * dLon;
  }

  Future<void> _showNearestTrashBins() async {
    if (_currentPosition == null) return;

    LatLng currentLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
    List<Map<String, dynamic>> filteredBins = trashBins.where((bin) {
      return bin['type'].contains(widget.result);
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
      expandedIndex = null;
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
      // 선택된 마커만 남기도록 처리
      _markers = {
        Marker(
          markerId: MarkerId(bin['address']),
          position: LatLng(bin['coordinate']['latitude'], bin['coordinate']['longitude']),
          infoWindow: InfoWindow(
            title: bin['location'],
            snippet: bin['type'].join(', '),
          ),
        )
      };
    });

    // 선택된 쓰레기통 위치로 지도 이동
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(bin['coordinate']['latitude'], bin['coordinate']['longitude']),
        15.0,
      ),
    );
  }

  void _confirmSelection() {
    setState(() {
      expandedIndex = null; // 카드 확장을 닫음
    });
  }

  void _resetSelection() {
    setState(() {
      selectedBin = null;
      expandedIndex = null;
      _markers.clear();
      _showNearestTrashBins(); // 초기 마커들 다시 표시
    });
  }

  @override
  void initState() {
    super.initState();
    _location.requestPermission().then((_) async {
      await _getCurrentLocation();
      await _loadTrashBinData();
      await _showNearestTrashBins();
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
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(37.5665, 126.9780),
                      zoom: 11.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                  ),
                ),
              ),
            ),
          ),
          if (nearestBins.isNotEmpty && selectedBin == null)
            Expanded(
              child: ListView.builder(
                itemCount: nearestBins.length,
                itemBuilder: (context, index) {
                  final bin = nearestBins[index];
                  return Card(
                    color: Colors.black54,
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            bin['location'],
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(bin['address'], style: TextStyle(color: Colors.white)),
                          onTap: () {
                            setState(() {
                              expandedIndex = expandedIndex == index ? null : index;
                            });
                          },
                        ),
                        if (expandedIndex == index)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                            child: ElevatedButton(
                              onPressed: () {
                                _selectBin(bin);
                                _confirmSelection();
                              },
                              child: const Text(
                                '선택하기',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (selectedBin != null)
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Card(
                color: Colors.black54,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(selectedBin!['location'],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      subtitle: Text(selectedBin!['address'], style: TextStyle(color: Colors.white)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _resetSelection,
                          child: const Text('포기하기', style: TextStyle(color: Colors.black87)),
                        ),
                        ElevatedButton(
                          onPressed: _completeTask,
                          child: const Text('완료하기', style: TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
