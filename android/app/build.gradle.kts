import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.walk"
    compileSdk = flutter.compileSdkVersion
    // 固定使用本机已完整安装的 NDK 27。
    // Flutter SDK 默认指向的 28.2.13676358 在本机是一次失败的下载
    // （目录仅剩 .installer，缺 source.properties），会导致配置阶段直接失败。
    // 本项目自身无 native C/C++ 代码，NDK 仅供依赖插件使用，27 可正常工作。
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // flutter_local_notifications 使用了 java.time 等新 API，
        // 需开启 core library desugaring 才能在低版本 Android 上运行，
        // 否则构建在 checkDebugAarMetadata 阶段即失败。
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.walk"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Mapbox token 从 local.properties 或环境变量注入，不硬编码进仓库。
        // 本地：android/local.properties 里加 MAPBOX_TOKEN=pk.xxx
        // CI：环境变量 MAPBOX_TOKEN（GitHub Secrets）。
        // token 缺失时注入空串，Dart 层已有占位界面兑底。
        val localProperties = Properties().apply {
            val f = rootProject.file("local.properties")
            if (f.exists()) load(FileInputStream(f))
        }
        resValue("string", "mapbox_access_token",
            System.getenv("MAPBOX_TOKEN")
                ?: localProperties.getProperty("MAPBOX_TOKEN")
                ?: "")
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

dependencies {
    // 与上方 isCoreLibraryDesugaringEnabled 配套：开启脱糖后必须提供该库，
    // 否则 Gradle 报 "coreLibraryDesugaring configuration contains no dependencies"。
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
