import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/maps_service.dart';
import 'package:geolocator/geolocator.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int? expandedIndex;
  Map<int, String> selectedDirection = {};
  List<BusLine> busLines = [];
  Position? userLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteBusLines();
  }

  Future<void> _loadFavoriteBusLines() async {
    try {
      // Get user location
      Position? position = await MapsService.getCurrentLocation();
      if (position != null) {
        userLocation = position;
      }

      // Get all bus lines and filter favorites
      List<BusLine> allBusLines = await FirestoreService.getAllBusLines();
      List<BusLine> favoriteBusLines = [];
      
      for (final busLine in allBusLines) {
        if (HomeScreenState.favoritesList.contains(busLine.lineId)) {
          favoriteBusLines.add(busLine);
        }
      }

      if (!mounted) return;
      setState(() {
        busLines = favoriteBusLines;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('الخطوط المحفوظة', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: busLines.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد خطوط في المفضلة',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: busLines.length,
                itemBuilder: (context, index) {
                  final busLine = busLines[index];
                  final isExpanded = expandedIndex == index;
                  final direction = selectedDirection[index] ?? 'go';
                  final color = _getBusLineColor(index);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: color, width: 2),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite,
                                          color: color,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            HomeScreenState.favoritesList.remove(busLine.lineId);
                                            _loadFavoriteBusLines();
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          busLine.name,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          busLine.lineId,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: direction == 'go' ? color : Colors.white,
                                            foregroundColor: direction == 'go' ? Colors.white : color,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: BorderSide(color: color),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              expandedIndex = index;
                                              selectedDirection[index] = 'go';
                                            });
                                          },
                                          child: const Text('ذهاب', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: direction == 'back' ? color : Colors.white,
                                            foregroundColor: direction == 'back' ? Colors.white : color,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: BorderSide(color: color),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              expandedIndex = index;
                                              selectedDirection[index] = 'back';
                                            });
                                          },
                                          child: const Text('عودة', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded && userLocation != null)
                          _TripDetails(
                            landmarks: FirestoreService.getLandmarksWithDistances(
                              busLine,
                              direction,
                              userLocation!,
                            ),
                            color: color,
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getBusLineColor(int index) {
    List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }
}

class _TripDetails extends StatelessWidget {
  final List<Map<String, dynamic>> landmarks;
  final Color color;
  const _TripDetails({required this.landmarks, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('اماكن المحطات', style: TextStyle(color: Colors.grey)),
              Text(' المسافة ', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          ...List.generate(landmarks.length, (i) {
            final landmark = landmarks[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(landmark['name'], style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(landmark['formattedDistance'], style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
