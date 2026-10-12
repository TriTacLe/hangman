plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "no.ntnu.idatt2506.hangman"
    // Pinned rather than taken from the installed SDK, so the version the
    // README names is the version anyone building this gets.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "no.ntnu.idatt2506.hangman"
        // 24 is the oldest Android the app is claimed to run on; 36 is what it
        // was developed and tested against on the Pixel 6 emulator.
        minSdk = 24
        targetSdk = 36
        // The app ships two languages, so there is no reason to carry every
        // locale Material has.
        resourceConfigurations += listOf("en", "nb")
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signed with the debug key on purpose. This app is handed in and
            // graded on an emulator, it is not going to Play, and a release
            // keystore would be a secret nobody else could reproduce.
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
