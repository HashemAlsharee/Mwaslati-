# Firestore Sample Data Structure

This document shows the expected Firestore structure for the Yemeni Bus Guide app.

## Collection: `bus_lines`

### Document Structure

```json
{
  "line_id": "AN3",
  "name": "العبور 2 - سنتر الياسمين",
  "polyline": [
    {"latitude": 24.7136, "longitude": 46.6753},
    {"latitude": 24.7236, "longitude": 46.6853},
    {"latitude": 24.7336, "longitude": 46.6953}
  ],
  "landmarks": {
    "go": [
      {
        "name": "العبور 2",
        "location": {"latitude": 24.7136, "longitude": 46.6753}
      },
      {
        "name": "موقف اتوبيسات العبور الجديدة",
        "location": {"latitude": 24.7236, "longitude": 46.6853}
      },
      {
        "name": "مدرسة الحرية",
        "location": {"latitude": 24.7336, "longitude": 46.6953}
      }
    ],
    "back": [
      {
        "name": "سنتر الياسمين",
        "location": {"latitude": 24.7436, "longitude": 46.7053}
      },
      {
        "name": "شارع 49",
        "location": {"latitude": 24.7536, "longitude": 46.7153}
      }
    ]
  },
  "active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Sample Documents

#### Document 1: AN3
```json
{
  "line_id": "AN3",
  "name": "العبور 2 - سنتر الياسمين",
  "polyline": [
    {"latitude": 24.7136, "longitude": 46.6753},
    {"latitude": 24.7236, "longitude": 46.6853},
    {"latitude": 24.7336, "longitude": 46.6953},
    {"latitude": 24.7436, "longitude": 46.7053}
  ],
  "landmarks": {
    "go": [
      {
        "name": "العبور 2",
        "location": {"latitude": 24.7136, "longitude": 46.6753}
      },
      {
        "name": "موقف اتوبيسات العبور الجديدة",
        "location": {"latitude": 24.7236, "longitude": 46.6853}
      },
      {
        "name": "مدرسة الحرية",
        "location": {"latitude": 24.7336, "longitude": 46.6953}
      },
      {
        "name": "التيسير ماركت",
        "location": {"latitude": 24.7436, "longitude": 46.7053}
      }
    ],
    "back": [
      {
        "name": "سنتر الياسمين",
        "location": {"latitude": 24.7436, "longitude": 46.7053}
      },
      {
        "name": "شارع 49",
        "location": {"latitude": 24.7336, "longitude": 46.6953}
      },
      {
        "name": "موقف اتوبيسات العبور الجديدة",
        "location": {"latitude": 24.7236, "longitude": 46.6853}
      },
      {
        "name": "العبور 2",
        "location": {"latitude": 24.7136, "longitude": 46.6753}
      }
    ]
  },
  "active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

#### Document 2: NA15
```json
{
  "line_id": "NA15",
  "name": "الأردنية إلى الحي الثالث",
  "polyline": [
    {"latitude": 24.8136, "longitude": 46.7753},
    {"latitude": 24.8236, "longitude": 46.7853},
    {"latitude": 24.8336, "longitude": 46.7953}
  ],
  "landmarks": {
    "go": [
      {
        "name": "الأردنية",
        "location": {"latitude": 24.8136, "longitude": 46.7753}
      },
      {
        "name": "الحي الثالث",
        "location": {"latitude": 24.8236, "longitude": 46.7853}
      },
      {
        "name": "شارع السنترال",
        "location": {"latitude": 24.8336, "longitude": 46.7953}
      }
    ],
    "back": [
      {
        "name": "الحي الثالث",
        "location": {"latitude": 24.8236, "longitude": 46.7853}
      },
      {
        "name": "الأردنية",
        "location": {"latitude": 24.8136, "longitude": 46.7753}
      }
    ]
  },
  "active": true,
  "created_at": "2024-01-01T00:00:00Z"
}
```

## Field Descriptions

### Required Fields
- `line_id` (string): Unique identifier for the bus line (e.g., "AN3", "NA15")
- `name` (string): Display name for the bus line in Arabic
- `polyline` (array): Array of GeoPoints representing the bus route
- `landmarks` (object): Object containing "go" and "back" arrays of landmarks
- `active` (boolean): Whether the bus line is currently active
- `created_at` (timestamp): When the bus line was created

### Landmark Structure
Each landmark in the `landmarks.go` and `landmarks.back` arrays contains:
- `name` (string): Name of the bus stop/landmark
- `location` (GeoPoint): Geographic coordinates of the landmark

## Setup Instructions

1. **Create Firestore Database**:
   - Go to Firebase Console
   - Create a new project or use existing project
   - Enable Firestore Database
   - Set up security rules

2. **Add Sample Data**:
   - Create collection named `bus_lines`
   - Add documents with the structure above
   - Use the sample data provided

3. **Configure App**:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Update API keys in the app

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bus_lines/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Testing

To test the integration:

1. **Add sample data** to Firestore
2. **Run the app** and grant location permissions
3. **Verify** that nearby bus lines are displayed
4. **Test** the "ذهاب" and "عودة" buttons
5. **Check** that distances are calculated correctly 