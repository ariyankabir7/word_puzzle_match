plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hindcash.wordpuzzlematch"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hindcash.wordpuzzlematch"
        manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("/home/kabir/Projects/keystore/vishal.jks")
            storePassword = "123456"
            keyAlias = "android"
            keyPassword = "123456"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

tasks.register<Copy>("copyReleaseArtifacts") {
    dependsOn("assembleRelease", "bundleRelease")
    into("/home/kabir/Projects/VishalProjects/apks_aabs")
    val vCode = android.defaultConfig.versionCode
    from(layout.buildDirectory.dir("outputs/apk/release")) {
        include("*.apk")
        rename { "WordPuzzleMatch_${vCode}.apk" }
    }
    from(layout.buildDirectory.dir("outputs/apk/release")) {
        include("*.apk")
        rename { "DeepWaterDiver_${vCode}.apk" }
    }
    from(layout.buildDirectory.dir("outputs/bundle/release")) {
        include("*.aab")
        rename { "WordPuzzleMatch_${vCode}.aab" }
    }
    from(layout.buildDirectory.dir("outputs/bundle/release")) {
        include("*.aab")
        rename { "DeepWaterDiver_${vCode}.aab" }
    }
}
