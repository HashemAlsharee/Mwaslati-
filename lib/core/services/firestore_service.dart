import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'maps_service.dart';
import 'logger_service.dart';

class BusLine {
  final String lineId;
  final String name;
  final List<LatLng> polyline;
  final List<Landmark> landmarksGo;
  final List<Landmark> landmarksBack;
  final bool active;
  final DateTime createdAt;

  BusLine({
    required this.lineId,
    required this.name,
    required this.polyline,
    required this.landmarksGo,
    required this.landmarksBack,
    required this.active,
    required this.createdAt,
  });

  factory BusLine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<LatLng> polyline = [];
    if (data['polyline'] != null) {
      polyline = MapsService.geoPointsToLatLngs(data['polyline']);
    }

    List<Landmark> landmarksGo = [];
    if (data['landmarks'] != null && data['landmarks']['go'] != null) {
      landmarksGo = (data['landmarks']['go'] as List)
          .map((landmark) => Landmark.fromMap(landmark))
          .toList();
    }

    List<Landmark> landmarksBack = [];
    if (data['landmarks'] != null && data['landmarks']['back'] != null) {
      landmarksBack = (data['landmarks']['back'] as List)
          .map((landmark) => Landmark.fromMap(landmark))
          .toList();
    }

    return BusLine(
      lineId: data['line_id'] ?? '',
      name: data['name'] ?? '',
      polyline: polyline,
      landmarksGo: landmarksGo,
      landmarksBack: landmarksBack,
      active: data['active'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}

class Landmark {
  final String name;
  final LatLng location;

  Landmark({
    required this.name,
    required this.location,
  });

  factory Landmark.fromMap(Map<String, dynamic> data) {
    return Landmark(
      name: data['name'] ?? '',
      location: MapsService.geoPointToLatLng(data['location']),
    );
  }
}

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bus_lines';

  /// Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // First check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        LoggerService.info('Firebase not initialized, attempting to initialize...');
        await Firebase.initializeApp();
      }
      
      await _firestore.collection('test').doc('test').get();
      LoggerService.info('Firebase connection successful');
      return true;
    } catch (e) {
      LoggerService.error('Firebase connection failed', e);
      return false;
    }
  }

  /// Add sample bus data for Sana'a, Yemen to Firestore
  static Future<void> addSanaaBusData() async {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection(_collectionName);

      // --- Bus Line 1: Al-Tahrir Square to Old City ---
      // final line1Ref = collection.doc('SNA1');
      // batch.set(line1Ref, {
      //   'line_id': 'SNA1',
      //   'name': 'خط 1: ميدان التحرير - صنعاء القديمة', // Line 1: Tahrir Square - Old City
      //   'active': true,
      //   'created_at': Timestamp.now(),
      //   'polyline': MapsService.latLngsToGeoPoints([
      //     const LatLng(15.3522, 44.1917), // Al-Tahrir Square
      //     const LatLng(15.3545, 44.1985), // Near Kuwait Hospital
      //     const LatLng(15.3560, 44.2040), // Main road
      //     const LatLng(15.3575, 44.2120), // Bab al-Yaman
      //   ]),
      //   'landmarks': {
      //     'go': [
      //       {'name': 'ميدان التحرير', 'location': const GeoPoint(15.3522, 44.1917)},
      //       {'name': 'شارع تعز', 'location': const GeoPoint(15.3545, 44.1985)},
      //       {'name': 'باب اليمن', 'location': const GeoPoint(15.3575, 44.2120)},
      //     ],
      //     'back': [
      //       {'name': 'باب اليمن', 'location': const GeoPoint(15.3575, 44.2120)},
      //       {'name': 'شارع تعز', 'location': const GeoPoint(15.3545, 44.1985)},
      //       {'name': 'ميدان التحرير', 'location': const GeoPoint(15.3522, 44.1917)},
      //     ],
      //   },
      // });

      // // --- Bus Line 2: Hadda Street to Sabaa Roundabout ---
      // final line2Ref = collection.doc('SNA2');
      // batch.set(line2Ref, {
      //   'line_id': 'SNA2',
      //   'name': 'خط 2: شارع حدة - جولة السبعين', // Line 2: Hadda St - Sabaa R/A
      //   'active': true,
      //   'created_at': Timestamp.now(),
      //   'polyline': MapsService.latLngsToGeoPoints([
      //     const LatLng(15.3288, 44.1883), // Hadda Street
      //     const LatLng(15.3350, 44.1920), // Mid Hadda
      //     const LatLng(15.3420, 44.1970), // Near Al-Sabeen Park
      //     const LatLng(15.3455, 44.2045), // Sabaa Roundabout
      //   ]),
      //   'landmarks': {
      //     'go': [
      //       {'name': 'بداية شارع حدة', 'location': const GeoPoint(15.3288, 44.1883)},
      //       {'name': 'مستشفى لبنان', 'location': const GeoPoint(15.3350, 44.1920)},
      //       {'name': 'جولة السبعين', 'location': const GeoPoint(15.3455, 44.2045)},
      //     ],
      //     'back': [
      //       {'name': 'جولة السبعين', 'location': const GeoPoint(15.3455, 44.2045)},
      //       {'name': 'مستشفى لبنان', 'location': const GeoPoint(15.3350, 44.1920)},
      //       {'name': 'نهاية شارع حدة', 'location': const GeoPoint(15.3288, 44.1883)},
      //     ],
      //   },
      // });

       final line3Ref = collection.doc('SNA3');
      batch.set(line3Ref, {
        'line_id': 'SNA3',
        'name': ' :  سيتي مارت - الرويشان', // Line 3
        'active': true,
        'created_at': Timestamp.now(),
        'polyline': MapsService.latLngsToGeoPoints([
          const LatLng(15.35988, 44.18915),
          const LatLng(15.35913, 44.18912),
          const LatLng(15.35895, 44.18912),
          const LatLng(15.35805, 44.1891),
          const LatLng(15.35802, 44.18909),
          const LatLng(15.35746, 44.18907),
          const LatLng(15.3573, 44.18906),
          const LatLng(15.35728, 44.18906),
          const LatLng(15.35674, 44.18904),
          const LatLng(15.35664, 44.18904),
          const LatLng(15.35569, 44.18901),
          const LatLng(15.3555, 44.18901),
          const LatLng(15.35525, 44.18901),
          const LatLng(15.35471, 44.18899),
          const LatLng(15.35443, 44.18899),
          const LatLng(15.3538, 44.18898),
          const LatLng(15.35329, 44.18897),
          const LatLng(15.35275, 44.18895),
          const LatLng(15.35271, 44.18895),
          const LatLng(15.35179, 44.18893),
          const LatLng(15.35134, 44.18892),
          const LatLng(15.35119, 44.18892),
          const LatLng(15.35095, 44.18893),
          const LatLng(15.35089, 44.18893),
          const LatLng(15.35077, 44.18894),
          const LatLng(15.35045, 44.189),
          const LatLng(15.35036, 44.18901),
          const LatLng(15.34998, 44.18908),
          const LatLng(15.34948, 44.18919),
          const LatLng(15.34898, 44.1893),
          const LatLng(15.34881, 44.18933),
          const LatLng(15.34845, 44.1894),
          const LatLng(15.34828, 44.18943),
          const LatLng(15.34739, 44.18959),
          const LatLng(15.34721, 44.18963),
          const LatLng(15.34719, 44.18954),
          const LatLng(15.34693, 44.18958),
          const LatLng(15.34673, 44.18963),
          const LatLng(15.34626, 44.18975),
          const LatLng(15.34586, 44.18989),
          const LatLng(15.34533, 44.19006),
          const LatLng(15.34521, 44.1901),
          const LatLng(15.34508, 44.19014),
          const LatLng(15.34469, 44.19025),
          const LatLng(15.3445, 44.19025),
          const LatLng(15.34418, 44.19035),
          const LatLng(15.34415, 44.19035),
          const LatLng(15.34411, 44.19037),
          const LatLng(15.34408, 44.19038),
          const LatLng(15.34404, 44.19039),
          const LatLng(15.34398, 44.19042),
          const LatLng(15.34381, 44.19047),
          const LatLng(15.3433, 44.19064),
          const LatLng(15.34296, 44.19076),
          const LatLng(15.3422, 44.19101),
          const LatLng(15.3419, 44.19112),
          const LatLng(15.34144, 44.19131),
          const LatLng(15.34114, 44.19142),
          const LatLng(15.34111, 44.19143),
          const LatLng(15.3406, 44.19161),
          const LatLng(15.34014, 44.19174),
          const LatLng(15.33965, 44.19189),
          const LatLng(15.33945, 44.19195),
          const LatLng(15.33851, 44.19228),
          const LatLng(15.33809, 44.19246),
          const LatLng(15.3375, 44.19265),
          const LatLng(15.33746, 44.19266),
          const LatLng(15.33686, 44.19287),
          const LatLng(15.33664, 44.19294),
          const LatLng(15.33661, 44.19295),
          const LatLng(15.3361, 44.19314),
          const LatLng(15.33567, 44.19328),
          const LatLng(15.33536, 44.1934),
          const LatLng(15.33517, 44.19345),
          const LatLng(15.33505, 44.19352),
          const LatLng(15.33493, 44.19361),
          const LatLng(15.33492, 44.19372),
          const LatLng(15.3349, 44.1941),
          const LatLng(15.3349, 44.19416),
          const LatLng(15.33486, 44.19482),
          const LatLng(15.33484, 44.19536),
          const LatLng(15.33484, 44.19547),
          const LatLng(15.33481, 44.19603),
          const LatLng(15.3348, 44.19626),
          const LatLng(15.33478, 44.19678),
          const LatLng(15.33477, 44.19682),
          const LatLng(15.33474, 44.19752),
          const LatLng(15.33474, 44.19756),
          const LatLng(15.33473, 44.19784),
          const LatLng(15.33472, 44.19803),
          const LatLng(15.33471, 44.19822),
          const LatLng(15.3347, 44.19845),
        ]),
        'landmarks': {
          'go': [
            {'name': 'seeds  ', 'location': const GeoPoint(15.341855, 44.191275)},
            {'name': 'rwishan ', 'location': const GeoPoint(15.334728, 44.198575)},
           
          ],
          'back': [
             {'name': 'seeds  ', 'location': const GeoPoint(15.341855, 44.191275)},
            {'name': 'rwishan ', 'location': const GeoPoint(15.334728, 44.198575)},
          ],
        },
      });

      final line4Ref = collection.doc('SNA4');
      batch.set(line4Ref, {
        'line_id': 'SNA4',
        'name': 'جامعه صنعاء - باب اليمن ', // Line 2: Hadda St - Sabaa R/A
        'active': true,
        'created_at': Timestamp.now(),
        'polyline': MapsService.latLngsToGeoPoints([
          const LatLng(15.3648, 44.18944),
          const LatLng(15.36467, 44.18966),
          const LatLng(15.36456, 44.18984),
          const LatLng(15.36417, 44.19047),
          const LatLng(15.36383, 44.191),
          const LatLng(15.3638, 44.19106),
          const LatLng(15.36365, 44.19133),
          const LatLng(15.36348, 44.19162),
          const LatLng(15.36337, 44.19183),
          const LatLng(15.36335, 44.19187),
          const LatLng(15.36332, 44.19187),
          const LatLng(15.36302, 44.19185),
          const LatLng(15.36241, 44.19188),
          const LatLng(15.36238, 44.19188),
          const LatLng(15.36166, 44.19194),
          const LatLng(15.36135, 44.19196),
          const LatLng(15.36099, 44.19198),
          const LatLng(15.36086, 44.19199),
          const LatLng(15.36074, 44.192),
          const LatLng(15.36055, 44.19203),
          const LatLng(15.36045, 44.19205),
          const LatLng(15.36039, 44.19207),
          const LatLng(15.36024, 44.19212),
          const LatLng(15.36011, 44.19217),
          const LatLng(15.35998, 44.19221),
          const LatLng(15.3596, 44.19236),
          const LatLng(15.35958, 44.19237),
          const LatLng(15.35907, 44.19256),
          const LatLng(15.35861, 44.1927),
          const LatLng(15.35854, 44.19272),
          const LatLng(15.35816, 44.19283),
          const LatLng(15.35768, 44.19302),
          const LatLng(15.35725, 44.19316),
          const LatLng(15.35723, 44.19317),
          const LatLng(15.3568, 44.19328),
          const LatLng(15.35644, 44.1934),
          const LatLng(15.35628, 44.19345),
          const LatLng(15.35626, 44.19345),
          const LatLng(15.35616, 44.19346),
          const LatLng(15.356, 44.19345),
          const LatLng(15.35583, 44.19344),
          const LatLng(15.35572, 44.19342),
          const LatLng(15.35557, 44.1934),
          const LatLng(15.35518, 44.1933),
          const LatLng(15.35513, 44.19329),
          const LatLng(15.35483, 44.19322),
          const LatLng(15.35448, 44.19313),
          const LatLng(15.35446, 44.19312),
          const LatLng(15.35394, 44.19294),
          const LatLng(15.35388, 44.19292),
          const LatLng(15.35358, 44.19278),
          const LatLng(15.35352, 44.19274),
          const LatLng(15.35345, 44.19269),
          const LatLng(15.35328, 44.19257),
          const LatLng(15.3532, 44.19254),
          const LatLng(15.35306, 44.19248),
          const LatLng(15.35283, 44.19243),
          const LatLng(15.35275, 44.19243),
          const LatLng(15.35221, 44.19237),
          const LatLng(15.35216, 44.19237),
          const LatLng(15.35196, 44.19234),
          const LatLng(15.35162, 44.1923),
          const LatLng(15.35157, 44.1923),
          const LatLng(15.35141, 44.19229),
          const LatLng(15.35133, 44.19229),
          const LatLng(15.35114, 44.19229),
          const LatLng(15.35095, 44.19228),
          const LatLng(15.35075, 44.19227),
          const LatLng(15.35069, 44.19226),
          const LatLng(15.35053, 44.19224),
          const LatLng(15.35036, 44.19217),
          const LatLng(15.3501, 44.19201),
          const LatLng(15.34993, 44.1919),
          const LatLng(15.3498, 44.19181),
          const LatLng(15.34971, 44.19174),
          const LatLng(15.34965, 44.19172),
          const LatLng(15.34956, 44.1917),
          const LatLng(15.3494, 44.19172),
          const LatLng(15.34876, 44.19179),
          const LatLng(15.34867, 44.19179),
          const LatLng(15.34832, 44.19183),
          const LatLng(15.34776, 44.19188),
          const LatLng(15.34742, 44.19191),
          const LatLng(15.34727, 44.19193),
          const LatLng(15.34721, 44.19194),
           const LatLng(15.34724, 44.19216),
          const LatLng(15.3473, 44.19257),
          const LatLng(15.34732, 44.19263),
          const LatLng(15.34735, 44.19288),
          const LatLng(15.34736, 44.19292),
          const LatLng(15.34742, 44.19319),
          const LatLng(15.34743, 44.19321),
          const LatLng(15.34756, 44.19352),
          const LatLng(15.34781, 44.19413),
          const LatLng(15.34781, 44.19414),
          const LatLng(15.34792, 44.19441),
          const LatLng(15.34799, 44.19455),
          const LatLng(15.34834, 44.19527),
          const LatLng(15.3484, 44.19538),
          const LatLng(15.34859, 44.19576),
          const LatLng(15.3487, 44.196),
          const LatLng(15.34872, 44.19603),
          const LatLng(15.34879, 44.19621),
          const LatLng(15.34883, 44.19626),
          const LatLng(15.34881, 44.19628),
          const LatLng(15.3488, 44.19631),
          const LatLng(15.34878, 44.19635),
          const LatLng(15.34878, 44.19639),
          const LatLng(15.34877, 44.19644),
          const LatLng(15.34877, 44.19648),
          const LatLng(15.34875, 44.19651),
          const LatLng(15.34875, 44.19654),
          const LatLng(15.34862, 44.19665),
          const LatLng(15.3485, 44.19675),
          const LatLng(15.34847, 44.19677),
          const LatLng(15.34837, 44.19687),
          const LatLng(15.3483, 44.19698),
          const LatLng(15.34807, 44.19713),
          const LatLng(15.3479, 44.19723),
          const LatLng(15.34773, 44.1973),
          const LatLng(15.34753, 44.19732),
          const LatLng(15.34733, 44.1974),
          const LatLng(15.34732, 44.1974),
          const LatLng(15.34706, 44.19744),
          const LatLng(15.34685, 44.19743),
          const LatLng(15.34671, 44.19739),
          const LatLng(15.3466, 44.19737),
          const LatLng(15.34649, 44.19738),
          const LatLng(15.34641, 44.19742),
          const LatLng(15.3465, 44.19768),
          const LatLng(15.34655, 44.19788),
          const LatLng(15.3466, 44.19796),
          const LatLng(15.34675, 44.19824),
          const LatLng(15.34698, 44.19867),
          const LatLng(15.34704, 44.1989),
          const LatLng(15.34665, 44.19901),
          const LatLng(15.34627, 44.19912),
          const LatLng(15.34621, 44.19914),
          const LatLng(15.34614, 44.19915),
          const LatLng(15.34607, 44.19917),
          const LatLng(15.34562, 44.19923),
          const LatLng(15.34549, 44.19888),
          const LatLng(15.34545, 44.19876),
          const LatLng(15.34542, 44.19868),
          const LatLng(15.34524, 44.19814),
          const LatLng(15.34517, 44.19794),
          const LatLng(15.34512, 44.1979),
          const LatLng(15.34511, 44.1979),
          const LatLng(15.34509, 44.1979),
          const LatLng(15.34507, 44.1979),
          const LatLng(15.34503, 44.19792),
          const LatLng(15.34502, 44.19793),
          const LatLng(15.34499, 44.198),
          const LatLng(15.34506, 44.19824),
          const LatLng(15.34514, 44.19853),
          const LatLng(15.34528, 44.19888),
          const LatLng(15.34542, 44.19925),
          const LatLng(15.34545, 44.19932),
          const LatLng(15.3456, 44.19974),
          const LatLng(15.34562, 44.19978),
          const LatLng(15.34571, 44.19983),
          const LatLng(15.34579, 44.20006),
          const LatLng(15.34592, 44.20041),
          const LatLng(15.34627, 44.20142),
          const LatLng(15.3465, 44.20195),
          const LatLng(15.34661, 44.2022),
          const LatLng(15.34663, 44.20226),
          const LatLng(15.3469, 44.20299),
          const LatLng(15.34691, 44.20301),
          const LatLng(15.34692, 44.20302),
          const LatLng(15.34692, 44.20304),
          const LatLng(15.34693, 44.20305),
          const LatLng(15.34694, 44.20306),
          const LatLng(15.34694, 44.20308),
          const LatLng(15.34695, 44.20309),
          const LatLng(15.34696, 44.20311),
          const LatLng(15.34696, 44.20312),
          const LatLng(15.34697, 44.20314),
          const LatLng(15.34698, 44.20315),
          const LatLng(15.34698, 44.20317),
          const LatLng(15.34699, 44.20318),
          const LatLng(15.34699, 44.2032),
          const LatLng(15.347, 44.20321),
          const LatLng(15.34701, 44.20322),
          const LatLng(15.34701, 44.20324),
          const LatLng(15.34702, 44.20325),
          const LatLng(15.34702, 44.20327),
          const LatLng(15.34703, 44.20328),
          const LatLng(15.34704, 44.2033),
          const LatLng(15.34704, 44.20331),
          const LatLng(15.34705, 44.20333),
          const LatLng(15.34705, 44.20334),
          const LatLng(15.34706, 44.20336),
          const LatLng(15.34706, 44.20337),
          const LatLng(15.34707, 44.20339),
          const LatLng(15.34708, 44.2034),
          const LatLng(15.34708, 44.20342),
          const LatLng(15.34709, 44.20343),
          const LatLng(15.34709, 44.20345),
          const LatLng(15.3471, 44.20346),
          const LatLng(15.34711, 44.20348),
          const LatLng(15.34711, 44.20349),
          const LatLng(15.34712, 44.20351),
          const LatLng(15.34712, 44.20352),
          const LatLng(15.34713, 44.20354),
          const LatLng(15.34713, 44.20355),
          const LatLng(15.34714, 44.20357),
          const LatLng(15.34714, 44.20358),
          const LatLng(15.34715, 44.2036),
          const LatLng(15.34721, 44.20374),
          const LatLng(15.34729, 44.20393),
          const LatLng(15.34729, 44.20395),
          const LatLng(15.34744, 44.20433),
          const LatLng(15.34747, 44.20441),
          const LatLng(15.34759, 44.20472),
          const LatLng(15.34777, 44.20523),
          const LatLng(15.34803, 44.20584),
          const LatLng(15.34806, 44.20589),
          const LatLng(15.34823, 44.20636),
          const LatLng(15.34851, 44.20711),
          const LatLng(15.34855, 44.20723),
          const LatLng(15.34869, 44.20758),
          const LatLng(15.34879, 44.20786),
          const LatLng(15.34891, 44.20821),
          const LatLng(15.34907, 44.20866),
          const LatLng(15.34912, 44.20883),
          const LatLng(15.34916, 44.20902),
          const LatLng(15.34918, 44.20907),
          const LatLng(15.34922, 44.20925),
          const LatLng(15.34925, 44.20938),
          const LatLng(15.34926, 44.20943),
          const LatLng(15.34929, 44.20956),
          const LatLng(15.3493, 44.20961),
          const LatLng(15.34937, 44.2099),
          const LatLng(15.34938, 44.20995),
          const LatLng(15.34939, 44.20997),
          const LatLng(15.34943, 44.21016),
          const LatLng(15.34946, 44.21027),
          const LatLng(15.3495, 44.21045),
          const LatLng(15.34952, 44.21052),
          const LatLng(15.34964, 44.21107),
          const LatLng(15.3497, 44.21129),
          const LatLng(15.34983, 44.21186),
          const LatLng(15.34986, 44.21202),
          const LatLng(15.35003, 44.21277),
          const LatLng(15.35011, 44.21314),
          const LatLng(15.35033, 44.21417),
          const LatLng(15.35034, 44.21423),
          const LatLng(15.35051, 44.21496),
          const LatLng(15.35041, 44.21497),
             
        ]),
        'landmarks': {
          'go': [
            {'name': 'بداية شارع حدة', 'location': const GeoPoint(15.3288, 44.1883)},
            {'name': 'مستشفى لبنان', 'location': const GeoPoint(15.3350, 44.1920)},
            {'name': 'جولة السبعين', 'location': const GeoPoint(15.3455, 44.2045)},
          ],
          'back': [
            {'name': 'جولة السبعين', 'location': const GeoPoint(15.3455, 44.2045)},
            {'name': 'مستشفى لبنان', 'location': const GeoPoint(15.3350, 44.1920)},
            {'name': 'نهاية شارع حدة', 'location': const GeoPoint(15.3288, 44.1883)},
          ],
        },
      });

      final line5Ref = collection.doc('SNA5');
      batch.set(line5Ref, {
        'line_id': 'SNA5',
        'name': 'شارع الزبيري - جولة ريماس', // Line 2: Hadda St - Sabaa R/A
        'active': true,
        'created_at': Timestamp.now(),
        'polyline': MapsService.latLngsToGeoPoints([
       const LatLng(15.34478, 44.19769),
const LatLng(15.34461, 44.19774),
const LatLng(15.34404, 44.19789),
const LatLng(15.34352, 44.19802),
const LatLng(15.34331, 44.19808),
const LatLng(15.34283, 44.19821),
const LatLng(15.34227, 44.19836),
const LatLng(15.34175, 44.1985),
const LatLng(15.3415, 44.19856),
const LatLng(15.34122, 44.1986),
const LatLng(15.34068, 44.19868),
const LatLng(15.34046, 44.19871),
const LatLng(15.34026, 44.19874),
const LatLng(15.34022, 44.19874),
const LatLng(15.34006, 44.19875),
const LatLng(15.33971, 44.19875),
const LatLng(15.3395, 44.19874),
const LatLng(15.33881, 44.19872),
const LatLng(15.33813, 44.19868),
const LatLng(15.33777, 44.19867),
const LatLng(15.33667, 44.19861),
const LatLng(15.33631, 44.19859),
const LatLng(15.33559, 44.19855),
const LatLng(15.33552, 44.19855),
const LatLng(15.33509, 44.19853),
const LatLng(15.33479, 44.19852),
const LatLng(15.3347, 44.19851),
const LatLng(15.33446, 44.19851),
const LatLng(15.33392, 44.1985),
const LatLng(15.33374, 44.19851),
const LatLng(15.33313, 44.19856),
const LatLng(15.33296, 44.1986),
const LatLng(15.33223, 44.19868),
const LatLng(15.33157, 44.19875),
const LatLng(15.33117, 44.19878),
const LatLng(15.33045, 44.19883),
const LatLng(15.32925, 44.19896),
const LatLng(15.32858, 44.19901),
const LatLng(15.3285, 44.19901),
const LatLng(15.32837, 44.19902),
const LatLng(15.32816, 44.19905),
const LatLng(15.32779, 44.1991),
const LatLng(15.32769, 44.19911),
const LatLng(15.32754, 44.19911),


        ]),
        'landmarks': {
          'go': [
            {'name': 'بداية شارع حدة', 'location': const GeoPoint(15.344855 ,44.197764 )},
            {'name': ' الديرة مول', 'location': const GeoPoint(15.340480, 44.198689)},
            {'name': 'مول الكميم', 'location': const GeoPoint(15.338163, 44.198683)},
              {'name': 'السفارة الليبيه', 'location': const GeoPoint(15.330776, 44.198951)},
          ],
          'back': [
            {'name': 'بداية شارع حدة', 'location': const GeoPoint(15.344855 ,44.197764 )},
            {'name': ' الديرة مول', 'location': const GeoPoint(15.340480, 44.198689)},
            {'name': 'مول الكميم', 'location': const GeoPoint(15.338163, 44.198683)},
              {'name': 'السفارة الليبيه', 'location': const GeoPoint(15.330776, 44.198951)},
          ],
        },
      });

      await batch.commit();
      await _firestore.collection(_collectionName).doc('SNA1').delete();
      LoggerService.info('Sana\'a bus data added successfully');
    } catch (e) {
      LoggerService.error('Error adding Sana\'a bus data', e);
    }
  }

  /// Get all active bus lines
  static Future<List<BusLine>> getAllBusLines() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('active', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => BusLine.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching bus lines', e);
      return [];
    }
  }

  /// Get nearby bus lines based on user location
  static Future<List<BusLine>> getNearbyBusLines(Position userLocation, {double threshold = 300}) async {
    try {
      List<BusLine> allBusLines = await getAllBusLines();
      List<BusLine> nearbyBusLines = [];

      for (BusLine busLine in allBusLines) {
        if (MapsService.isBusLineNearby(userLocation, busLine.polyline, threshold: threshold)) {
          nearbyBusLines.add(busLine);
        }
      }

      return nearbyBusLines;
    } catch (e) {
      LoggerService.error('Error fetching nearby bus lines', e);
      return [];
    }
  }

  /// Calculate distances to landmarks for a specific direction
  static List<Map<String, dynamic>> calculateLandmarkDistances(
    Position userLocation,
    List<Landmark> landmarks,
  ) {
    return landmarks.map((landmark) {
      double distance = MapsService.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        landmark.location.latitude,
        landmark.location.longitude,
      );

      return {
        'name': landmark.name,
        'distance': distance,
        'formattedDistance': MapsService.formatDistance(distance),
      };
    }).toList();
  }

  /// Get landmarks with distances for a bus line in a specific direction
  static List<Map<String, dynamic>> getLandmarksWithDistances(
    BusLine busLine,
    String direction,
    Position userLocation,
  ) {
    List<Landmark> landmarks = direction == 'go' 
        ? busLine.landmarksGo 
        : busLine.landmarksBack;

    return calculateLandmarkDistances(userLocation, landmarks);
  }
}