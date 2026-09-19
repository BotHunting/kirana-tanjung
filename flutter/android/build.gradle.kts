buildscript {
    ext.kotlin_version = '1.9.20'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2' // <-- Ubah di sini
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
android {
    namespace = "com.example.kirana_tanjung"
    compileSdk = 34 // Optimasi untuk Android 14

    // HAPUS baris ndkVersion agar menggunakan default Flutter SDK
    // ndkVersion "25.0.3" 

    defaultConfig {
        applicationId = "com.example.kirana_tanjung"
        // Sinkronisasi dengan requirements package_info_plus & printing
        minSdk = 21 
        targetSdk = 34
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
            // Optimasi ukuran APK
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
