# Seller Registration Form Implementation

## Overview
This document describes the complete seller registration form implementation for the FixRight application.

## Features Implemented

### 1. **Seller Form (sellerForm.dart)**
A complete seller registration form with the following features:

#### Read-Only User Fields
- **First Name** - Prefilled from user data (locked with lock icon)
- **Last Name** - Prefilled from user data (locked with lock icon)
- **Mobile Number** - Prefilled from user data (locked with lock icon)

```dart
_buildReadOnlyField(
  label: 'First Name',
  value: firstName,
  icon: Icons.person,
)
```

#### CNIC Document Uploads (Testing)
Two image picker implementations:
- **CNIC Front** - Gallery picker with visual feedback
- **CNIC Back** - Gallery picker with visual feedback

Currently uses dummy image URLs:
```dart
'cnicFrontUrl': 'https://i.dawn.com/primary/2015/12/566683b21750f.jpg',
'cnicBackUrl': 'https://i.dawn.com/primary/2015/12/566683b21750f.jpg',
```

#### Skills Multi-Select
- **50+ Common Domestic Services** including:
  - Carpenter, Electrician, Plumber, Mechanic, Painter, AC Technician
  - Cleaner, Driver, Gardener, Mason, Welder, CCTV Installer
  - Appliance Repair, Roofer, Locksmith, Solar Technician
  - And 35+ more...

- **UI Implementation**:
  - Grid-based layout (2 columns)
  - Toggle selection with visual feedback
  - Display count of selected skills
  - Check icon when selected

```dart
GridView.count(
  crossAxisCount: 2,
  children: allSkills.map((skill) {
    final isSelected = selectedSkills.contains(skill);
    // Render skill chip with toggle
  }).toList(),
)
```

### 2. **Firestore Data Structure**

When user submits the seller form, a document is created in the `sellers` collection:

```
sellers/
  ├── {userId1}/
  │   ├── uid: "user-id-1"
  │   ├── firstName: "John"
  │   ├── lastName: "Doe"
  │   ├── mobileNumber: "03001234567"
  │   ├── cnicFrontUrl: "https://..."
  │   ├── cnicBackUrl: "https://..."
  │   ├── skills: ["Carpenter", "Electrician", "Plumber"]
  │   ├── status: "submitted"
  │   └── createdAt: Timestamp(...)
  │
  └── {userId2}/
      └── ...
```

### 3. **Seller Status System**

The app tracks seller approval status with three states:

#### Status States:
1. **No Seller Document** → "Become a Seller" (white button, clickable)
2. **status: "submitted"** → "Submitted (Under Review)" (orange button, disabled)
3. **status: "approved" + role: "seller"** → "Seller" (switch appears, enabled)

#### Status Flow in Code:

```dart
// Get seller status
Future<String> _getSellerStatus() async {
  final sellerDoc = await _firestore.collection('sellers').doc(phoneDocId).get();
  if (sellerDoc.exists) {
    return sellerDoc.data()?['status'] ?? 'none';
  }
  return 'none';
}

// Display appropriate label
String _getSellerLabel() {
  if (UserRole == 'seller') {
    return 'Seller';
  } else if (sellerStatus == 'submitted') {
    return 'Submitted (Under Review)';
  } else {
    return 'Become a Seller';
  }
}
```

### 4. **Profile Screen Integration**

#### Before Seller Registration
```
┌─────────────────────────┐
│ My Profile              │
│ [Avatar] Name  Balance  │
├─────────────────────────┤
│ [Become a Seller]       │  ← White button
└─────────────────────────┘
```

#### After Submission
```
┌─────────────────────────┐
│ My Profile              │
│ [Avatar] Name  Balance  │
├─────────────────────────┤
│ [Submitted (Under...)]  │  ← Orange button (disabled)
└─────────────────────────┘
```

#### After Admin Approval
```
┌─────────────────────────┐
│ My Profile              │
│ [Avatar] Name  Balance  │
├─────────────────────────┤
│ Seller Mode  | ◎────●   │  ← Switch appears (enabled)
└─────────────────────────┘
```

## Admin Approval Flow (Backend)

### Scenario 1: Request Additional KYC
```dart
// Admin updates the seller document
sellers/{userId} → update({
  status: 'submitted',  // Reset for resubmission
  requestedKYC: {
    type: 'video_verification',
    message: 'Please submit video confirmation',
    timestamp: Timestamp.now()
  }
})
```

### Scenario 2: Approve Seller
```dart
// Admin updates both collections
1. sellers/{userId} → update({
  status: 'approved',
  approvedAt: Timestamp.now(),
  approvedBy: 'admin-user-id'
})

2. users/{userId} → update({
  Role: 'seller'
})
```

## Code Structure

### sellerForm.dart
- `_SellerformState` - Main state management
- `_initializeUserData()` - Load user info
- `_pickImage()` - Image selection from gallery
- `_toggleSkill()` - Toggle skill selection
- `_submitSellerForm()` - Submit to Firestore
- `_buildReadOnlyField()` - Render read-only fields
- `_buildImagePicker()` - Render image picker UI

### ProfileScreen.dart Additions
- `sellerStatus` - Track seller approval status
- `_getSellerStatus()` - Fetch status from Firestore
- `_getSellerLabel()` - Get display label
- Updated seller button with status-based UI

## Testing Checklist

- [ ] Form displays with prefilled user data (read-only)
- [ ] CNIC front image picker works
- [ ] CNIC back image picker works
- [ ] Skills multi-select toggles properly
- [ ] Submit button is disabled until all fields are filled
- [ ] Firestore document created with correct structure
- [ ] ProfileScreen shows "Become a Seller" initially
- [ ] ProfileScreen shows "Submitted (Under Review)" after submission
- [ ] Submit button is disabled in "Submitted" state
- [ ] Admin can manually update status to "approved"
- [ ] ProfileScreen shows seller switch after approval
- [ ] Seller switch works to toggle seller mode

## Future Enhancements

1. **Real Image Upload** - Replace dummy URLs with Cloudinary upload
2. **Video KYC** - Add video verification flow
3. **Admin Panel** - Build UI for admin approval
4. **Verification Progress** - Show submission progress
5. **Rejection Handling** - Handle and display rejection reasons
6. **Skills Management** - Allow editing skills after approval
7. **Rating System** - Display seller ratings/reviews

## Dependencies

- `cloud_firestore` - Database
- `image_picker` - Image selection from gallery
- `flutter/material.dart` - UI components

## Notes

- Images are currently selected but not uploaded (dummy URLs used)
- Admin approval must be done directly in Firestore or via admin panel
- User data is passed from ProfileScreen to Sellerform
- Status checks happen on profile load
- Seller switch only appears when role is 'seller'
