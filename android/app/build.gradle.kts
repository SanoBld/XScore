plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.xscore"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.xscore"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("xscore-release.keystore") // committed in android/app/
            storePassword = "xscore123"
            keyAlias = "xscore"
            keyPassword = "xscore123"
        }
    }

    buildTypes {
        release {
            // Same key every build -> updates always install cleanly
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}