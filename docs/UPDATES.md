# Fami in-app updates

Fami is intended to update itself on Android without manually moving a new APK to the phone.

## What the user experience will be

1. Fami checks a tiny HTTPS JSON manifest when the app opens.
2. If the manifest's build number is newer than the installed build, Fami shows an update popup.
3. The user taps **Download Update**.
4. Fami downloads the APK inside the app and verifies its SHA-256 checksum when provided.
5. Android opens the system package installer.
6. The user confirms the update.

Android does **not** let a normal sideloaded application silently replace itself. The confirmation screen is an Android security requirement. The important improvement is that the family no longer has to transfer/download the APK manually.

## Update manifest

The app reads the URL supplied at build time through:

`FAMI_UPDATE_MANIFEST_URL`

Example:

```json
{
  "build": 3,
  "version": "0.3.0",
  "apkUrl": "https://updates.example.com/Fami-0.3.0.apk",
  "sha256": "PUT_REAL_SHA256_HERE",
  "notes": "The next Fami release.",
  "required": false
}
```

The update manifest and APK must be reachable over HTTPS by the phone.

## Important: the repository is private

Do **not** embed a GitHub personal access token in the APK just so Fami can download private GitHub release assets. Anyone who obtains the APK could extract that token.

Instead, publish only release artifacts through a dedicated update host, for example:

- a small Cloudflare R2 bucket / Worker,
- a Supabase Storage bucket or backend endpoint,
- another HTTPS endpoint that exposes only signed Fami releases.

The source code can remain private.

## Stable Android signing key

Android will only install a new APK over an existing Fami installation if both APKs are signed with the same signing key.

Before distributing the first real family build, create one permanent release keystore and keep it backed up securely. Do not regenerate it for every GitHub Actions run.

Recommended GitHub secrets for CI later:

- `FAMI_ANDROID_KEYSTORE_BASE64`
- `FAMI_ANDROID_KEY_ALIAS`
- `FAMI_ANDROID_KEY_PASSWORD`
- `FAMI_ANDROID_STORE_PASSWORD`

The current prototype build workflow still needs the permanent signing pass before it should be treated as the long-term installed family version.

## Android permission

The updater requests Android's `REQUEST_INSTALL_PACKAGES` permission. On Android 8+ the user may need to allow Fami as an install source the first time. Android remains in control of the final install confirmation.
