# Mwasalati_Firestore_Architecture_v1.1

---

# Architecture Version Information

| Attribute             | Value                                          |
| --------------------- | ---------------------------------------------- |
| Architecture Name     | Mwasalati Firestore Architecture               |
| Architecture Version  | v1.1                                           |
| Architecture Type     | Hybrid Transit-Oriented Firestore Architecture |
| Database Technology   | Firebase Firestore                             |
| Application Framework | Flutter                                        |
| Programming Language  | Dart                                           |
| Maps Provider         | Google Maps API                                |
| Route Representation  | Encoded Polyline                               |
| Document Status       | Proposed for Review                                       |
| Architecture State    | Proposed Revision - Pending Approval                            |
| Intended Usage        | Single Source of Truth (SSOT)                  |
| Last Approved Phase   | Phase 6.6                                      |
| Effective Date        | May 2026                                       |

## Revision History

| Version | Status | Revision Summary |
| --- | --- | --- |
| v1.0 | Superseded baseline upon approval of v1.1 | Previously approved architecture baseline. |
| v1.1 | Proposed for review | Removes Audit Logs, the `audit_logs` collection, AuditLog modeling, dashboard module, and audit-specific permissions and relationships. Other approved architecture decisions are retained unless explicitly noted. |

**Revision control:** v1.1 becomes the authoritative SSOT only after the project owner formally reviews and approves this revision. Until then, v1.0 remains the previously approved baseline.

---

# Approval Status

This document is the proposed v1.1 revision of the Mwasalati database architecture. It becomes the official approved architecture and replaces v1.0 as the SSOT only after formal review and approval.

Upon approval, this document shall be considered the authoritative reference for:

* Chapter 3 Database Design
* ERD Development
* UML Modeling
* Firestore Implementation
* Admin Dashboard Development
* Future System Expansion
* Application Maintenance Activities

No further architectural modifications shall be treated as approved unless formally reviewed and approved in a subsequent version.

Current Status:

```text
PROPOSED FOR REVIEW
PENDING FORMAL APPROVAL
VERSION 1.1
```

---

# 1. Introduction

## 1.1 Overview

Mwasalati is an intelligent online public bus transportation guidance system designed to assist passengers in Yemen in identifying suitable public transportation routes, locating nearby bus lines, and navigating efficiently between origins and destinations.

The system initially targets Sana'a city while maintaining architectural support for future expansion to additional Yemeni cities.

The application is developed using Flutter and Firebase Firestore, and integrates geospatial capabilities through Google Maps APIs and encoded polyline technologies.

The database architecture was designed to satisfy both academic and production-oriented requirements.

The architecture follows Firestore best practices and emphasizes:

* Scalability
* Maintainability
* Administrative manageability
* Performance optimization
* Future extensibility
* Firestore compliance

---

## 1.2 Purpose

The purpose of this document is to provide a unified architectural specification describing the approved Firestore data model used by Mwasalati.

This document serves as the Single Source of Truth (SSOT) for all future design, implementation, and documentation activities.

---

## 1.3 Scope

The architecture covers:

* Public transportation data management
* Bus line management
* Directional route representation
* Landmark management
* Administrative dashboard support
* Transportation dataset versioning
* Soft deletion mechanisms
* Firestore optimization techniques
* Security considerations
* Scalability planning

The architecture intentionally excludes unsupported or rejected modules.

---

# 2. Architecture Goals

The proposed architecture was designed according to the following objectives.

---

## 2.1 Scalability

The system shall support future expansion to multiple Yemeni cities without requiring structural redesign.

Examples include:

* Sana'a
* Aden
* Taiz
* Ibb
* Al Hudaydah
* Mukalla

---

## 2.2 Maintainability

Transportation entities shall be separated into independent collections to simplify maintenance activities and reduce coupling.

---

## 2.3 Firestore Optimization

The architecture shall:

* Minimize document sizes
* Reduce read costs
* Support efficient indexing
* Avoid oversized documents
* Support Firestore querying patterns

---

## 2.4 Administrative Manageability

The architecture shall support a web-based administration dashboard enabling transportation data management.

---

## 2.5 Future Extensibility

The architecture shall support future integration of:

* Artificial Intelligence modules
* Recommendation systems
* Additional transportation services
* Analytics capabilities

---

## 2.6 Academic Readiness

The architecture shall support:

* Chapter 3 documentation
* ERD generation
* UML modeling
* Software Design Documentation
* Graduation Project Deliverables

---

# 3. Approved Features

The following features were explicitly approved.

---

## 3.1 Transportation Features

| Feature                      | Status   |
| ---------------------------- | -------- |
| Multi-city Support           | Approved |
| Direct Routes                | Approved |
| Transfer Routes              | Approved |
| Dynamic Transfer Calculation | Approved |
| Nearby Bus Detection         | Approved |
| Google Maps Integration      | Approved |
| Walking Directions           | Approved |
| Independent Landmarks        | Approved |
| Encoded Polyline Storage     | Approved |

---

## 3.2 User Features

| Feature             | Status   |
| ------------------- | -------- |
| Guest User Access   | Approved |
| User Authentication | Rejected |
| Cloud Favorites     | Rejected |
| Local Favorites     | Approved |

---

## 3.3 Administrative Features

| Feature             | Status   |
| ------------------- | -------- |
| Web Admin Dashboard | Approved |
| Super Admin Role    | Approved |
| Version Publishing  | Approved |
| Soft Delete         | Approved |
| Audit Logging       | Excluded |

---

## 3.4 Versioning Features

| Feature                  | Status   |
| ------------------------ | -------- |
| Dataset Versioning       | Approved |
| Single Published Version | Approved |
| Rollback Capability      | Approved |

---

# 4. Decision Log

| Decision                             | Status   | Date Approved | Notes                           |
| ------------------------------------ | -------- | ------------- | ------------------------------- |
| Hybrid Transit-Oriented Architecture | Approved | Phase 5       | Selected architecture style     |
| Multi-city Support                   | Approved | Phase 2       | Supports Yemeni cities          |
| Guest User Model                     | Approved | Phase 2       | No authentication               |
| Super Admin Role                     | Approved | Phase 2       | Single administrative role      |
| Independent Landmarks                | Approved | Phase 2       | Landmarks separated from routes |
| Dynamic Transfers                    | Approved | Phase 2       | Algorithmically calculated      |
| Encoded Polyline                     | Approved | Phase 5       | Replaced GeoPoint arrays        |
| RouteDirection Entity                | Approved | Phase 5       | Top-level collection            |
| Versioning                           | Approved | Phase 5       | Uses versionId                  |
| Soft Delete                          | Approved | Final Audit   | Uses status enum                |
| Audit Logs                           | Removed  | v1.1          | Excluded from current scope     |
| Local Favorites                      | Approved | Phase 2       | Device-side persistence         |
| Web Dashboard                        | Approved | Phase 6       | Administrative interface        |
| Route Color                          | Approved | Phase 6       | Visualization support           |
| Line Code                            | Approved | Phase 6       | Transportation identifier       |
| Fare Object                          | Approved | Phase 6       | amount + currency               |
| createdBy / updatedBy                | Approved | Final Audit   | Administrative metadata         |
| Single Published Version Constraint  | Approved | Final Audit   | Exactly one published version   |
| Architecture Freeze                  | Superseded | v1.0        | Prior baseline; v1.1 pending approval |


---

# 5. Collections

The proposed v1.1 Firestore database consists of seven physical collections.

The architecture additionally defines one logical entity used exclusively for ERD and UML modeling.

---

## 5.1 Physical Collections

```text
cities

bus_lines

route_directions

landmarks

admins

settings

transport_versions
```

---

## 5.2 Logical Entities

Logical entities are introduced to improve ERD normalization and UML representation.

Logical entities are not stored inside Firestore.

Approved Logical Entity:

```text
DirectionLandmark
```

Purpose:

Represent Many-to-Many associations between RouteDirection and Landmark in conceptual database models.

---

# 6. Document Schemas

---

# 6.1 Collection: cities

## Purpose

Stores supported Yemeni cities.

---

## Document Identifier

```text
cityId
```

Examples:

```text
sanaa

aden

taiz

ibb
```

---

## Schema

| Field     | Type      | Required |
| --------- | --------- | -------- |
| cityId    | String    | Yes      |
| nameAr    | String    | Yes      |
| nameEn    | String    | Yes      |
| country   | String    | Yes      |
| status    | Enum      | Yes      |
| versionId | String    | Yes      |
| createdAt | Timestamp | Yes      |
| updatedAt | Timestamp | Yes      |
| createdBy | String    | Yes      |
| updatedBy | String    | Yes      |

---

## Status Enumeration

```text
ACTIVE

ARCHIVED
```

---

# Example Document

```json
{
"cityId":"sanaa",

"nameAr":"صنعاء",

"nameEn":"Sanaa",

"country":"YE",

"status":"ACTIVE",

"versionId":"v3",

"createdAt":Timestamp,

"updatedAt":Timestamp,

"createdBy":"admin001",

"updatedBy":"admin001"
}
```

---

---

# 6.2 Collection: bus_lines

## Purpose

Stores transportation line metadata.

Route geometry is intentionally excluded.

---

## Document Identifier

```text
lineId
```

---

## Schema

| Field       | Type      | Required |
| ----------- | --------- | -------- |
| lineId      | String    | Yes      |
| lineCode    | String    | Yes      |
| cityId      | String    | Yes      |
| nameAr      | String    | Yes      |
| nameEn      | String    | Yes      |
| routeColor  | String    | Yes      |
| status      | Enum      | Yes      |
| versionId   | String    | Yes      |
| createdAt   | Timestamp | Yes      |
| updatedAt   | Timestamp | Yes      |
| publishedAt | Timestamp | No       |
| createdBy   | String    | Yes      |
| updatedBy   | String    | Yes      |

---

# Example Document

```json
{
"lineId":"line001",

"lineCode":"SAN-015",

"cityId":"sanaa",

"nameAr":"التحرير - الجامعة",

"nameEn":"Altahrir - University",

"routeColor":"#1976D2",

"status":"ACTIVE",

"versionId":"v3",

"createdAt":Timestamp,

"updatedAt":Timestamp,

"publishedAt":Timestamp,

"createdBy":"admin001",

"updatedBy":"admin001"
}
```

---

---

# 6.3 Collection: route_directions

## Purpose

Represents directional transportation paths.

Each line currently supports:

GO

BACK

The architecture supports future expansion.

---

## Document Identifier

```text
directionId
```

---

## Schema

| Field            | Type          | Required |
| ---------------- | ------------- | -------- |
| directionId      | String        | Yes      |
| lineId           | String        | Yes      |
| cityId           | String        | Yes      |
| direction        | Enum          | Yes      |
| displayNameAr    | String        | Yes      |
| displayNameEn    | String        | Yes      |
| startLandmarkId  | String        | Yes      |
| endLandmarkId    | String        | Yes      |
| encodedPolyline  | String        | Yes      |
| landmarkIds      | Array<String> | Yes      |
| fare             | Object        | Yes      |
| distanceKm       | Double        | Yes      |
| estimatedMinutes | Integer       | Yes      |
| status           | Enum          | Yes      |
| versionId        | String        | Yes      |
| createdAt        | Timestamp     | Yes      |
| updatedAt        | Timestamp     | Yes      |
| createdBy        | String        | Yes      |
| updatedBy        | String        | Yes      |

---

## Direction Enum

```text
GO

BACK
```

---

## Fare Object

```json
fare{

amount

currency

}
```

---

## Example Document

```json
{
"directionId":"dir001",

"lineId":"line001",

"cityId":"sanaa",

"direction":"GO",

"displayNameAr":"التحرير ← الجامعة",

"displayNameEn":"Altahrir → University",

"startLandmarkId":"land001",

"endLandmarkId":"land010",

"encodedPolyline":"xxxxx",

"landmarkIds":[

"land001",

"land005",

"land010"

],

"fare":{

"amount":100,

"currency":"YER"

},

"distanceKm":12.5,

"estimatedMinutes":35,

"status":"ACTIVE",

"versionId":"v3",

"createdAt":Timestamp,

"updatedAt":Timestamp,

"createdBy":"admin001",

"updatedBy":"admin001"
}
```

---

---

# 6.4 Collection: landmarks

## Purpose

Searchable transportation landmarks.

---

## Document Identifier

```text
landmarkId
```

---

## Schema

| Field      | Type      |
| ---------- | --------- |
| landmarkId | String    |
| cityId     | String    |
| nameAr     | String    |
| nameEn     | String    |
| category   | Enum      |
| location   | GeoPoint  |
| status     | Enum      |
| createdAt  | Timestamp |
| updatedAt  | Timestamp |
| createdBy  | String    |
| updatedBy  | String    |

---

## Categories

```text
EDUCATION

HOSPITAL

GOVERNMENT

MARKET

MALL

PARK

STATION

OTHER
```

---

---

# 6.5 Collection: admins

## Purpose

Stores Super Administrators.

---

## Schema

| Field     | Type      |
| --------- | --------- |
| uid       | String    |
| email     | String    |
| role      | Enum      |
| status    | Enum      |
| createdAt | Timestamp |

---

## Roles

```text
SUPER_ADMIN
```

---

---

# 6.6 Collection: settings

Document:

```text
general
```

---

## Schema

| Field              | Type      |
| ------------------ | --------- |
| transferThreshold  | Integer   |
| walkingThreshold   | Integer   |
| maintenanceMessage | String    |
| currentVersionId   | String    |
| enabledCities      | Array     |
| updatedAt          | Timestamp |
| updatedBy          | String    |

---

---

# 6.7 Collection: transport_versions

## Schema

| Field       | Type      |
| ----------- | --------- |
| versionId   | String    |
| description | String    |
| published   | Boolean   |
| publishedAt | Timestamp |
| createdAt   | Timestamp |
| createdBy   | String    |

---

## Constraint

Exactly one document may have:

```text
published=true
```

Validation is enforced by the Admin Dashboard.

---


---

# 7. Relationships

---

## City

```text
City

1 ---- N BusLine


1 ---- N Landmark


1 ---- N RouteDirection
```

---

## BusLine

```text
BusLine


1 ---- N RouteDirection
```

Current implementation:

GO

BACK

Supported.

---

## RouteDirection

```text
RouteDirection


N ---- 1 BusLine


N ---- 1 City
```

---

## Landmark

Conceptual ERD Relationship

```text
RouteDirection


N ---- M Landmark
```

Represented logically by:

```text
DirectionLandmark
```

Firestore Implementation:

```text
landmarkIds[]
```


---

## TransportVersion

```text
TransportVersion


1 ---- N City


1 ---- N BusLine


1 ---- N RouteDirection
```

---

# 8. Firestore Indexes

Recommended Composite Indexes.

---

## route_directions

```text
cityId + status


lineId + direction


versionId + status
```

---

## bus_lines

```text
cityId + status
```

---

## landmarks

```text
cityId + status
```

---

## transport_versions

```text
published
```

---

# 9. Denormalization Strategy

Firestore denormalization was intentionally applied.

Approved Cases:

---

### RouteDirection

Stores:

```text
cityId
```

Although derivable from:

```text
BusLine
```

Reason:

Efficient filtering.

Dashboard support.

Reduced reads.

---

### RouteDirection

Stores:

```text
landmarkIds[]
```

Instead of a physical bridge collection.

Reason:

Firestore optimization.

Reduced reads.

Simpler implementation.

---

### Route Geometry

Stored as:

```text
Encoded Polyline
```

Instead of:

```text
List<GeoPoint>
```

Reason:

Smaller documents.

Lower costs.

Improved scalability.

---

# 10. Admin Module

## 10.1 Purpose

The Admin Module provides a centralized web-based management interface for transportation data administration.

The module enables transportation dataset management without direct interaction with the Firebase Console.

The Admin Module is intended for operational maintenance activities and transportation data publishing.

---

## 10.2 Administrative Role

Only one administrative role is supported.

```text
SUPER_ADMIN
```

Additional administrative roles were explicitly excluded from Architecture v1.1.

Excluded Roles

```text
CityAdmin

DataEntry

TransportAuthority
```

---

# 10.3 Dashboard Modules

The approved dashboard structure consists of:

```text
Dashboard

├── Cities

├── BusLines

├── RouteDirections

├── Landmarks

├── Settings

├── Versions
└── Profile
```

---

# 10.4 Cities Module

## Supported Operations

Create City

Edit City

Archive City

Activate City

View City Information

---

Managed Collection

```text
cities
```

---

---

# 10.5 Bus Lines Module

## Supported Operations

Create BusLine

Edit BusLine

Archive BusLine

Restore BusLine

View BusLine

---

Managed Collection

```text
bus_lines
```

---

Displayed Information

```text
Line Code


Arabic Name


English Name


Route Color


Version


Status
```

---

---

# 10.6 Route Directions Module

This module manages directional transportation paths.

---

Supported Operations

Create Direction

Edit Direction

Archive Direction

Restore Direction

Update Polyline

Modify Fare

Modify Estimated Duration

Modify Landmarks

---

Managed Collection

```text
route_directions
```

---

Direction Types

```text
GO


BACK
```

---

Displayed Information

```text
Direction Name


Polyline


Distance


Duration


Fare


Status
```

---

---

# 10.7 Landmarks Module

Supported Operations

Create Landmark

Edit Landmark

Archive Landmark

Restore Landmark

---

Managed Collection

```text
landmarks
```

---

Supported Categories

```text
EDUCATION


HOSPITAL


GOVERNMENT


MARKET


MALL


PARK


STATION


OTHER
```

---

---

# 10.8 Settings Module

Supported Operations

Modify Transfer Threshold

Modify Walking Threshold

Modify Maintenance Message

Select Current Dataset Version

---

Managed Collection

```text
settings
```

Document

```text
general
```

---

---

# 10.9 Versions Module

Supported Operations

Create Version

Publish Version

Rollback

Archive Version

---

Managed Collection

```text
transport_versions
```

---

Constraint

Exactly one version may have:

```text
published=true
```

Validation is implemented through the Admin Dashboard.

---

Displayed Information

```text
Version


Description


Publish Status


Publish Date
```

---


# 11. Favorites Module

Status

```text
APPROVED
```

---

Purpose

Store user favorite routes locally.

---

Storage Location

Local Device Storage

---

Cloud Synchronization

Not Supported.

---

Firestore Collection

None.

---

User Authentication

Not Required.

---

Scope

Guest User Only.

---

Implementation Technology

Not specified by Architecture v1.1.

---

# 12. Reports Module

Status

```text
EXCLUDED
```

---

Reason

Reports functionality was not approved during the architecture workshops.

The architecture reserves the possibility for future implementation.

---

Firestore Collection

None.

---

Dashboard Module

None.

---

Version

Future Expansion.

---

# 13. Statistics Module

Status

```text
EXCLUDED
```

---

Reason

Statistics and analytics capabilities were explicitly rejected.

The architecture reserves the possibility for future implementation.

---

Firestore Collection

None.

---

Analytics

Not Supported.

---

Version

Future Expansion.

---

# 14. Settings Module

Status

```text
APPROVED
```

---

Managed Collection

```text
settings
```

---

Document

```text
general
```

---

Supported Parameters

Transfer Threshold

Walking Threshold

Maintenance Message

Current Version

Enabled Cities

---

Example

```json
{

"transferThreshold":150,


"walkingThreshold":500,


"maintenanceMessage":"",


"currentVersionId":"v3",


"enabledCities":[

"sanaa",

"aden"

],


"updatedAt":Timestamp,


"updatedBy":"admin001"

}
```

---

# 15. Security Considerations

The architecture adopts a read-public and write-restricted access model.

---

## Guest Users

Permissions

Read Transportation Data

Read Landmarks

Read Published Dataset

---

Restrictions

No Write Access

No Administrative Access

---

---

Accessible Collections

```text
cities


bus_lines


route_directions


landmarks
```

---

---

## Super Admin

Permissions

Full CRUD

Version Publishing

Settings Modification

Transportation Management
---

Accessible Collections

```text
admins


settings


transport_versions
```

---

---

## Security Model

Firestore Security Rules are recommended.

Architecture v1.1 defines access policies only.

Detailed rule implementation is outside the scope of this document.

---

Recommended Strategy

```text
Public Read


Authenticated Admin Write
```

---

Authentication Requirement

Super Admin authentication is required.

Authentication provider selection is outside the scope of Architecture v1.1.

---

# 16. Scalability Plan

## 16.1 Objective

The architecture was designed to support future growth while maintaining acceptable Firestore performance, low operational costs, and manageable administration.

The proposed design supports horizontal expansion without requiring structural modifications.

---

## 16.2 Multi-City Expansion

Architecture v1.1 supports the addition of new cities through the `cities` collection.

Examples:

```text
sanaa
aden
taiz
ibb
hodeidah
mukalla
```

No schema modifications are required when introducing new cities.

---

## 16.3 Transportation Growth

The architecture is expected to support:

### Current Scope

Approximately:

```text
50 Bus Lines

100 Route Directions
```

---

### Future Scope

Approximately:

```text
300 Bus Lines

600 Route Directions
```

---

### Scalability Considerations

The architecture minimizes read operations through controlled denormalization and optimized indexing.

Encoded Polyline storage significantly reduces document sizes compared to GeoPoint arrays.

---

## 16.4 Future Expansion Areas

The following capabilities were intentionally reserved for future versions:

* Reports
* Statistics
* AI Recommendation Engine
* Additional Administrative Roles
* Authentication for End Users
* Cloud Favorites Synchronization
* Public APIs
* Transit Analytics

---

# 17. ERD-ready Structure

---

## 17.1 Physical Collections

```text
cities

bus_lines

route_directions

landmarks

admins

settings

transport_versions
```

---

## 17.2 Logical ERD Entities

Logical entities exist exclusively for conceptual modeling.

---

### DirectionLandmark

Purpose:

Represent Many-to-Many relationships between RouteDirection and Landmark.

Firestore implementation uses:

```text
landmarkIds[]
```

---

## 17.3 Relationships

---

### City

```text
City

1 ------- N BusLine

1 ------- N Landmark

1 ------- N RouteDirection
```

---

### BusLine

```text
BusLine

1 ------- N RouteDirection
```

Current implementation supports:

```text
GO

BACK
```

Future extensibility remains possible.

---

### RouteDirection

```text
RouteDirection

N ------- 1 BusLine


N ------- 1 City
```

---

### RouteDirection ↔ Landmark

Conceptual Relationship:

```text
RouteDirection


N ------- M


Landmark
```

Logical Representation:

```text
DirectionLandmark
```

Physical Representation:

```text
landmarkIds[]
```


---

### TransportVersion

```text
TransportVersion


1 ------- N City


1 ------- N BusLine


1 ------- N RouteDirection
```

---

# 18. UML-ready Entities

---

## City

Attributes:

```text
cityId

nameAr

nameEn

country

status

versionId

createdAt

updatedAt

createdBy

updatedBy
```

---

## BusLine

Attributes:

```text
lineId

lineCode

cityId

nameAr

nameEn

routeColor

status

versionId

createdAt

updatedAt

publishedAt

createdBy

updatedBy
```

---

## RouteDirection

Attributes:

```text
directionId

lineId

cityId

direction

displayNameAr

displayNameEn

startLandmarkId

endLandmarkId

encodedPolyline

landmarkIds

fare

distanceKm

estimatedMinutes

status

versionId

createdAt

updatedAt

createdBy

updatedBy
```

---

## Landmark

Attributes:

```text
landmarkId

cityId

nameAr

nameEn

category

location

status

createdAt

updatedAt

createdBy

updatedBy
```

---

## Admin

Attributes:

```text
uid

email

role

status

createdAt
```

---

## Settings

Attributes:

```text
transferThreshold

walkingThreshold

maintenanceMessage

currentVersionId

enabledCities

updatedAt

updatedBy
```

---

## TransportVersion

Attributes:

```text
versionId

description

published

publishedAt

createdAt

createdBy
```


---

## DirectionLandmark

Logical Entity Only.

Attributes:

```text
id

directionId

landmarkId
```

---

# 19. Assumptions

The following assumptions were accepted during Architecture v1.1 development.

---

## Estimated Duration

Field:

```text
estimatedMinutes
```

Represents an administratively managed value.

The mechanism used to calculate this field is outside the scope of Architecture v1.1.

---

## Distance

Field:

```text
distanceKm
```

Represents a stored transportation metric.

Calculation methodology is outside the scope of Architecture v1.1.

---

## Version Publishing

Exactly one version may be published.

Enforcement is performed through the Admin Dashboard.

No Firestore-side enforcement mechanism was approved.

---

## Favorites Storage

Favorites persistence is approved.

Storage technology selection remains implementation-dependent.

Examples may include:

* SharedPreferences
* Hive

Architecture v1.1 does not mandate a specific technology.

---

## Security Rules

Architecture v1.1 defines access policies only.

Detailed Firestore rule implementation remains an implementation activity.

---

# 20. Consolidated Decision Log

| Decision                    | Status   | Notes                    |
| --------------------------- | -------- | ------------------------ |
| Hybrid Transit Architecture | Approved | Selected Architecture    |
| Multi-city Support          | Approved | Yemeni Cities            |
| Guest Users                 | Approved | No Authentication        |
| Independent Landmarks       | Approved | Dedicated Collection     |
| RouteDirection Collection   | Approved | Top-level Collection     |
| Encoded Polyline            | Approved | Firestore Optimization   |
| Dynamic Transfers           | Approved | Algorithmic              |
| Local Favorites             | Approved | Device-side Persistence  |
| Super Admin                 | Approved | Single Role              |
| Web Dashboard               | Approved | Administrative Interface |
| Versioning                  | Approved | versionId                |
| Soft Delete                 | Approved | status Enum              |
| Audit Logging Removed       | Proposed | Excluded from v1.1 scope |
| Fare Ownership              | Approved | RouteDirection           |
| Route Color Ownership       | Approved | BusLine                  |
| Single Published Version    | Approved | Dashboard Validation     |
| createdBy / updatedBy       | Approved | Administrative metadata        |
| Architecture Freeze         | Pending Review | v1.1 proposed; v1.0 remains baseline until approval |

---

# 21. Architecture Version Information

| Attribute            | Value                            |
| -------------------- | -------------------------------- |
| Architecture Name    | Mwasalati Firestore Architecture |
| Architecture Version | v1.1                             |
| Database Type        | Firebase Firestore               |
| Architecture Style   | Hybrid Transit-Oriented          |
| Architecture State   | Frozen                           |
| Document Type        | SSOT                             |
| Effective Version    | v1.1                             |
| Status               | Proposed for Review                         |

---

# 22. Approval Status

This document constitutes the proposed v1.1 database architecture specification for the Mwasalati project, pending formal approval.

Upon approval, it shall be considered the authoritative reference for:

* Chapter 3
* ERD Design
* UML Modeling
* Firestore Implementation
* Admin Dashboard Development
* Future Application Maintenance
* Transportation Dataset Management

Any modifications introduced after approval of Architecture v1.1 require formal review and approval.

---

# SSOT Status

```text
Mwasalati Firestore Architecture v1.1

PROPOSED FOR REVIEW

PENDING FORMAL APPROVAL

INTENDED SINGLE SOURCE OF TRUTH AFTER APPROVAL

READY FOR:

Chapter 3
ERD
UML
Firestore Development
Admin Dashboard Development
Future Expansion
```

---


