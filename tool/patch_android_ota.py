from pathlib import Path

manifest_path = Path("android/app/src/main/AndroidManifest.xml")
if not manifest_path.exists():
    raise SystemExit("AndroidManifest.xml not found. Run flutter create first.")

text = manifest_path.read_text(encoding="utf-8")

permissions = [
    '<uses-permission android:name="android.permission.INTERNET"/>',
    '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>',
]

for permission in permissions:
    if permission not in text:
        marker = "<manifest"
        end = text.find(">", text.find(marker))
        text = text[: end + 1] + "\n    " + permission + text[end + 1 :]

provider = """        <provider
            android:name="sk.fourq.otaupdate.OtaUpdateFileProvider"
            android:authorities="${applicationId}.ota_update_provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/filepaths" />
        </provider>
"""

if "OtaUpdateFileProvider" not in text:
    text = text.replace("    </application>", provider + "    </application>")

manifest_path.write_text(text, encoding="utf-8")

xml_dir = Path("android/app/src/main/res/xml")
xml_dir.mkdir(parents=True, exist_ok=True)
(xml_dir / "filepaths.xml").write_text(
    """<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <files-path name="internal_apk_storage" path="ota_update/"/>
</paths>
""",
    encoding="utf-8",
)



build_gradle_path = Path("android/app/build.gradle.kts")
if not build_gradle_path.exists():
    raise SystemExit("android/app/build.gradle.kts not found.")

gradle = build_gradle_path.read_text(encoding="utf-8")

if "isCoreLibraryDesugaringEnabled = true" not in gradle:
    gradle = gradle.replace(
        "compileOptions {\n",
        "compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n",
        1,
    )

if 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")' not in gradle:
    dependencies_block = """
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

"""
    flutter_marker = 'flutter {\n'
    if flutter_marker in gradle:
        gradle = gradle.replace(flutter_marker, dependencies_block + flutter_marker, 1)
    else:
        gradle += "\n" + dependencies_block

build_gradle_path.write_text(gradle, encoding="utf-8")

print("Configured Android manifest and desugaring for Fami OTA updates.")
