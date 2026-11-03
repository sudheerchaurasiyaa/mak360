# MAK360

Flutter application for MAK360 Car Garage with customer and owner experiences backed by Firebase.

## Included functionality

- One persistent Firebase login for both roles
- Customer email/password registration, email verification, Google sign-in, and password reset
- Owner sign-in through the same screen; owner accounts cannot self-register or promote themselves
- Firestore profiles, vehicles, wash requests, pickup coordinates, chat, status updates, and notification inboxes
- Google Maps place redirect and driving directions to MAK360 Car Garage (`12.7866625, 77.7448906`)
- Firebase Cloud Messaging token registration and Cloud Functions for booking, status, and chat notifications
- Deny-by-default Firestore and Storage rules with owner/customer separation
- Release builds require a private upload keystore and never silently use the debug key

## Firebase configuration still required

The screenshots supplied with the project contain the project metadata, but not the generated Android SDK configuration. Download `google-services.json` for Android app `com.mak360.mak360` in Firebase project `mak360` and place it at:

```text
android/app/google-services.json
```

Add these debug certificate fingerprints to that Android app before downloading the file:

```text
SHA-1   E0:BD:55:DD:6A:FE:EE:CF:BB:E9:30:DA:DC:47:17:B5:AA:7E:43:1D
SHA-256 1B:EC:EF:F3:57:BB:83:DA:58:5E:21:5D:D2:52:AE:11:92:A0:6A:8A:13:61:0D:55:BD:FF:98:BB:65:8C:A7:86
```

Also add the release/upload certificate fingerprints when the production keystore is created. Google sign-in will not work on a build whose SHA fingerprint is absent from Firebase.

## Firebase console checklist

1. Enable Email/Password and Google providers in Authentication.
2. Create the default Firestore database in `asia-south1` (Mumbai).
3. Use a Blaze plan before deploying Cloud Functions; Firestore and Auth can be tested independently first.
4. From this directory, deploy the backend:

   ```powershell
   firebase login
   firebase use mak360
   firebase deploy --only firestore:rules,firestore:indexes,functions
   ```

5. Create the owner in Firebase Authentication, then provision the owner role from an authenticated administrator environment:

   ```powershell
   cd functions
   gcloud auth application-default login
   npm run set-owner -- owner@example.com
   ```

   This writes both an Admin custom claim and a protected `users/{uid}` owner document. Customers can only create `role: customer` documents under the supplied rules.

## Android release signing

Create a private upload keystore, copy `android/key.properties.example` to `android/key.properties`, and replace the placeholder values. Both `key.properties` and `upload-keystore.jks` are ignored by Git. Back up the keystore securely; payment-enabled releases must never use the debug signing key.

## Verification

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

The app deliberately shows a clear Firebase setup screen when the native configuration file is absent instead of failing at startup.
