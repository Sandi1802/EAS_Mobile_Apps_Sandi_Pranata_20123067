import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val dartEnvironmentVariables = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val dartDefines = project.property("dart-defines") as String
    dartDefines.split(",").forEach {
        val decoded = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
        val split = decoded.split("=", limit = 2)
        if (split.size == 2) {
            dartEnvironmentVariables[split[0]] = split[1]
        }
    }
}

android {
    namespace = "com.example.mobile_apps"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        val flavor = dartEnvironmentVariables["FLAVOR"] ?: "dev"
        applicationId = "com.example.mobile_apps"
        if (flavor == "dev") {
            applicationIdSuffix = ".dev"
        }
        
        val appName = dartEnvironmentVariables["APP_NAME"] ?: "DigiNews"
        manifestPlaceholders["appName"] = appName
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
