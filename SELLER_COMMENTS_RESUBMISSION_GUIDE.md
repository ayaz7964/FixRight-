# Seller Form - Comments & Resubmission System

## Overview
Enhanced the seller registration form to support admin comments and seller resubmission workflow.

## New Features Added

### 1. **Admin Comments Field**
Admin can now add comments to a seller's application in Firestore:

```firestore
sellers/{userId}
├── comments: "Please provide clearer CNIC images, current ones are blurry"
├── status: "submitted"
└── ...
```

### 2. **Seller Resubmission Flow**

**Workflow:**
1. Seller submits form → status: "submitted"
2. Admin reviews and adds comments → `comments: "..."`
3. Seller opens form again → sees admin comments
4. Seller addresses feedback and resubmits
5. Comments cleared → status: "submitted" (ready for review again)

### 3. **Auto-Load Existing Data**
When seller opens the form for resubmission:
- Previously selected skills are pre-populated ✓
- Admin comments are displayed ✓
- Form title changes to "Update Your Application"
- Button text changes to "Update & Resubmit Application"

## Code Implementation

### New State Variables
```dart
String sellerStatus = '';           // Track current status
String adminComments = '';          // Store admin feedback
bool isResubmission = false;        // Is this a resubmission?
String? existingSellerDocId;        // Reference to existing doc
```

### Check Existing Seller Document
```dart
Future<void> _checkExistingSellerDocument() async {
  final sellerDoc = await _firestore.collection('sellers').doc(widget.uid).get();
  if (sellerDoc.exists) {
    // Load existing data, status, and comments
    setState(() {
      sellerStatus = data?['status'] ?? '';
      adminComments = data?['comments'] ?? '';
      isResubmission = true;
      selectedSkills = List<String>.from(data?['skills'] ?? []);
    });
  }
}
```

### Admin Feedback Display
```dart
if (isResubmission && adminComments.isNotEmpty)
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      border: Border.all(color: Colors.blue.shade300),
    ),
    child: Column(
      children: [
        Text('Admin Feedback', style: ...),
        Text(adminComments, style: ...),
        Text('Please address the feedback and resubmit...'),
      ],
    ),
  )
```

### Form Submission with Merge
```dart
await _firestore.collection('sellers').doc(widget.uid).set({
  'uid': widget.uid,
  'firstName': firstName,
  // ... other fields
  'status': 'submitted',
  'comments': '',  // Clear previous comments
  'updatedAt': Timestamp.now(),
}, SetOptions(merge: true));  // Merge with existing document
```

## Firestore Document Structure

### Initial Submission
```json
{
  "uid": "+923237964483",
  "firstName": "User",
  "lastName": "Account",
  "mobileNumber": "+923001234567",
  "cnicFrontUrl": "https://...",
  "cnicBackUrl": "https://...",
  "skills": ["Driver", "Cleaner", "Plumbing Repair"],
  "status": "submitted",
  "comments": "",
  "createdAt": Timestamp(2026-02-04),
  "updatedAt": Timestamp(2026-02-04)
}
```

### After Admin Adds Comments
```json
{
  ...
  "status": "submitted",
  "comments": "Please provide clearer CNIC images. Current ones are blurry.",
  "updatedAt": Timestamp(2026-02-04, Admin update)
}
```

### After Seller Resubmits
```json
{
  ...
  "skills": ["Driver", "Cleaner"],  // Updated skills
  "status": "submitted",
  "comments": "",  // Cleared
  "updatedAt": Timestamp(2026-02-04, Seller resubmission)
}
```

### After Admin Approves
```json
{
  ...
  "status": "approved",
  "comments": "",
  "approvedAt": Timestamp(2026-02-04),
  "approvedBy": "admin-id"
}
```

## UI Changes

### First Time (No Comments)
```
┌─────────────────────────────────┐
│ Become a Seller                 │
├─────────────────────────────────┤
│ Your Information                │
│ [First Name] [locked]           │
│ [Last Name] [locked]            │
│ [Mobile] [locked]               │
├─────────────────────────────────┤
│ CNIC Documents                  │
│ [CNIC Front picker]             │
│ [CNIC Back picker]              │
├─────────────────────────────────┤
│ Select Your Skills              │
│ [Skills grid 2x2]               │
├─────────────────────────────────┤
│ [Submit Seller Application]     │
└─────────────────────────────────┘
```

### Resubmission with Comments
```
┌─────────────────────────────────┐
│ Update Your Application         │
├─────────────────────────────────┤
│ ℹ️  Admin Feedback                │
│ "Please provide clearer CNIC    │
│  images. Current ones are       │
│  blurry."                       │
│ Please address the feedback...  │
├─────────────────────────────────┤
│ Status: Under Review            │
├─────────────────────────────────┤
│ [Pre-filled form]               │
├─────────────────────────────────┤
│ [Update & Resubmit Application] │
└─────────────────────────────────┘
```

### After Approval
```
┌─────────────────────────────────┐
│ Update Your Application         │
├─────────────────────────────────┤
│ ✓ Status: Approved              │
├─────────────────────────────────┤
│ [Form fields]                   │
└─────────────────────────────────┘
```

## Admin Update (Firebase Console)

To add comments and send back for revision:

```firestore
1. Go to: sellers/{userId}
2. Update field 'comments' with feedback:
   "Please update your skills list and provide 
    higher resolution CNIC photos."
3. Keep status as 'submitted'
4. Seller will see feedback on next open
```

## User Journey

### Path 1: Approval
```
Seller submits → Under Review → Admin approves → Role updated to 'seller'
```

### Path 2: Revision Requested
```
Seller submits → Under Review → Admin adds comments → 
Seller sees feedback → Updates data → Resubmits → Under Review → 
Admin approves → Role updated to 'seller'
```

### Path 3: Multiple Revisions
```
Seller submits → Comments → Revises → Resubmits → 
Comments → Revises → Resubmits → Approved
```

## Testing Checklist

- [ ] First-time submission works (no pre-filled data)
- [ ] Seller document created with correct structure
- [ ] Manually add comments in Firestore
- [ ] Open form again - see admin comments displayed
- [ ] Skills are pre-populated from previous submission
- [ ] Form title shows "Update Your Application"
- [ ] Resubmit button text shows "Update & Resubmit Application"
- [ ] Comments are cleared after resubmission
- [ ] updatedAt timestamp is refreshed
- [ ] Admin can approve and user Role auto-updates
- [ ] ProfileScreen shows correct status label

## Future Enhancements

1. **In-App Notification** - Notify seller when admin adds comments
2. **Timestamp Display** - Show when admin added comments
3. **Admin Name** - Display which admin reviewed the application
4. **Rejection Reason** - Add rejection status with reason
5. **Multiple Comments** - Store comment history with dates
6. **Email Notifications** - Send email when comments are added
7. **Auto-Reply Messages** - Predefined comment templates for admin

## Notes

- Comments are cleared on each resubmission (fresh start)
- Skills are preserved from previous submission for convenience
- Status always goes back to "submitted" after resubmission
- Admin approval auto-syncs Role to "seller" in users collection
- merge: true ensures we don't lose other fields when updating
- UpdatedAt timestamp tracks when seller resubmits

## Dependencies

- `cloud_firestore` - Database operations
- `image_picker` - Image selection
- `flutter/material.dart` - UI components

No syntax errors ✅
