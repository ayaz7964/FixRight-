# Google Maps API Configuration Guide

## Step 1: Get Your Google Maps API Key

### For Development:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - **Maps Static API** (for static map images)
   - **Directions API** (for navigation)
   - **Geocoding API** (for address conversion)

4. Create an API key:
   - Go to **Credentials**
   - Click **Create Credentials** → **API Key**
   - Copy the generated key

5. Set up restrictions (Optional but recommended):
   - Restrict to Android/iOS package names
   - Restrict API usage to only the APIs you enabled

## Step 2: Add API Key to Your App

### Option A: In Code (Development Only)
Edit `lib/src/pages/LocationMapScreen.dart`:

```dart
// Find this line (around line 120):
'&key=AIzaSyDummy123'

// Replace with your actual key:
'&key=YOUR_GOOGLE_MAPS_API_KEY'
```

### Option B: Environment Variables (Recommended)
Create a `.env` file in project root:
```
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Then update LocationMapScreen to use it.

## Step 3: Platform-Specific Configuration

### Android
Edit `android/app/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>
```

### iOS
Edit `ios/Runner/GoogleService-Info.plist`:
```xml
<key>API_KEY</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>
```

## Step 4: Test the Integration

1. Run the app:
   ```bash
   flutter run
   ```

2. Navigate to Profile → "View on Map"

3. Verify:
   - [ ] Location map displays
   - [ ] Address shows correctly (not "Unknown")
   - [ ] "Open in Google Maps" button works
   - [ ] Coordinates display properly

4. From Home screen, tap location icon:
   - [ ] SellerDirectoryScreen loads
   - [ ] Sellers display with distances
   - [ ] Can open each seller's map

## Troubleshooting

### "Unknown, Unknown" Still Showing
- **Cause**: Location permission denied
- **Fix**: Grant location permission in settings

### Map image not loading
- **Cause**: Invalid or missing API key
- **Fix**: 
  1. Verify API key in code
  2. Check API key restrictions
  3. Enable Maps Static API in Cloud Console

### Geocoding returns "Unknown"
- **Cause**: Coordinates not saved in Firebase or invalid
- **Fix**: 
  1. Go to Profile → Edit
  2. Re-grant location permission
  3. Save profile again
  4. Check Firebase for latitude/longitude fields

### Distance showing as "Distance unknown"
- **Cause**: Buyer's location not accessible
- **Fix**: Grant location permission to app

## Security Notes

⚠️ **IMPORTANT**: Never commit your API key to version control!

For production:
1. Use environment variables
2. Restrict API key to specific package names
3. Monitor API usage in Cloud Console
4. Set up billing alerts

## Cost Considerations

Google Maps APIs are free with quotas:
- **Maps Static API**: 25,000 free requests/day
- **Directions API**: 25,000 free requests/day
- **Geocoding API**: 5,000 free requests/day

After exceeding quotas, standard pricing applies (~$5-10 per 1000 requests)

## Testing Without Real API Key

For testing, you can:
1. Use a temporary dummy key to test UI
2. Mock location data in Firebase
3. Use coordinates: 27.7243556, 68.8220514 (Sukkur, Pakistan)

## Documentation Links

- [Google Maps API Docs](https://developers.google.com/maps)
- [Static Maps API](https://developers.google.com/maps/documentation/maps-static)
- [Directions API](https://developers.google.com/maps/documentation/directions)
- [Geocoding API](https://developers.google.com/maps/documentation/geocoding)
