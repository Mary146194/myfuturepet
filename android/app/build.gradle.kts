plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myfuturepet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.myfuturepet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // ar_flutter_plugin_2 (SceneView ARCore) needs Android 9.
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // One fixed key (from CI secrets) so a new APK installs over the old one.
    // Without MFP_KEYSTORE_PATH, builds fall back to the per-machine debug key.
    val sharedKeystore = System.getenv("MFP_KEYSTORE_PATH")
    signingConfigs {
        if (sharedKeystore != null) {
            create("shared") {
                storeFile = file(sharedKeystore)
                storePassword = System.getenv("MFP_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("MFP_KEY_ALIAS")
                keyPassword = System.getenv("MFP_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        debug {
            if (sharedKeystore != null) signingConfig = signingConfigs.getByName("shared")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Only for ArCoreApk.checkAvailability (MainActivity); no AR session yet.
    implementation("com.google.ar:core:1.45.0")
}
