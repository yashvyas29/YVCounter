plugins {
    id("com.android.application")
    // id("kotlin-android")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

val keyProperties = Properties().apply {
    val keyPropertiesFile = rootProject.file("key.properties")
    if (keyPropertiesFile.exists()) {
        keyPropertiesFile.reader(Charsets.UTF_8).use { load(it) }
    }
}

val detKeyAlias = keyProperties.getProperty("keyAlias")
require(detKeyAlias != null) { "keyAlias not found in key.properties file." }

val detKeyPassword = keyProperties.getProperty("keyPassword")
require(detKeyPassword != null) { "keyPassword not found in key.properties file." }

val detStoreFile = keyProperties.getProperty("storeFile")
require(detStoreFile != null) { "storeFile not found in key.properties file." }

val detStorePassword = keyProperties.getProperty("storePassword")
require(detStorePassword != null) { "storePassword not found in key.properties file." }

android {
    namespace = "com.yash.YVCounter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_24
        targetCompatibility = JavaVersion.VERSION_24
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.yash.YVCounter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Expose serverClientId from key.properties or fallback to google-services.json
        val serverClientIdFromKey: String? = keyProperties.getProperty("serverClientId")
        var serverClientIdFromJson: String? = null
        val googleServicesFile = rootProject.file("app/google-services.json")
        if (googleServicesFile.exists()) {
            try {
                val jsonText = googleServicesFile.readText(Charsets.UTF_8)
                val slurper = groovy.json.JsonSlurper()
                val parsed = slurper.parseText(jsonText) as Map<*, *>
                val clients = (parsed["client"] as? List<*>) ?: emptyList<Any>()
                clients.forEach { client ->
                    val oauthClients = (client as? Map<*, *>)?.get("oauth_client") as? List<*>
                    oauthClients?.forEach { oauth ->
                        val map = oauth as? Map<*, *>
                        val clientType = map?.get("client_type")?.toString()?.toIntOrNull()
                        if (clientType == 3) {
                            serverClientIdFromJson = map["client_id"] as? String
                        }
                    }
                }
            } catch (e: Exception) {
                // ignore parsing errors and fallback to key.properties
                println("${e.toString()}")
            }
        }
        val serverClientIdProp: String? = serverClientIdFromKey ?: serverClientIdFromJson
        buildConfigField("String", "SERVER_CLIENT_ID", serverClientIdProp?.let { "\"$it\"" } ?: "\"\"")
    }

    signingConfigs {
        create("release") {
            keyAlias = detKeyAlias
            keyPassword = detKeyPassword
            storeFile = file(detStoreFile)
            storePassword = detStorePassword
        }
    }

    buildTypes {
        getByName("release") {
            // Signing config for the release build.
            signingConfig = signingConfigs.getByName("release")

            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")

            // Enables code shrinking, obfuscation, and optimization for only
            // your project's release build type. Make sure to use a build
            // variant with `debuggable false`.
            isMinifyEnabled = true // Enable code shrinking for release builds

            // Enables resource shrinking, which is performed by the
            // Android Gradle plugin.
            isShrinkResources = true

            // Includes the default ProGuard rules files that are packaged with
            // the Android Gradle plugin. To learn more, go to the section about
            // R8 configuration files.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_24)
        freeCompilerArgs.addAll(
            listOf(
                "-Xjvm-default=all",
                "-opt-in=kotlin.RequiresOptIn"
            )
        )
    }
}

// Task: generate a small Dart file with the server client id so Dart can read it synchronously.
tasks.register("generateServerClientId") {
    doLast {
        val props = Properties()
        val keyFile = rootProject.file("key.properties")
        var serverId: String? = null
        if (keyFile.exists()) {
            keyFile.reader(Charsets.UTF_8).use { props.load(it) }
            serverId = props.getProperty("serverClientId")
        }
        if (serverId.isNullOrEmpty()) {
            val googleServicesFile = rootProject.file("app/google-services.json")
            if (googleServicesFile.exists()) {
                try {
                    val jsonText = googleServicesFile.readText(Charsets.UTF_8)
                    val slurper = groovy.json.JsonSlurper()
                    val parsed = slurper.parseText(jsonText) as Map<*, *>
                    val clients = (parsed["client"] as? List<*>) ?: emptyList<Any>()
                    clients.forEach { client ->
                        val oauthClients = (client as? Map<*, *>)?.get("oauth_client") as? List<*>
                        oauthClients?.forEach { oauth ->
                            val map = oauth as? Map<*, *>
                            val clientType = map?.get("client_type")?.toString()?.toIntOrNull()
                            if (clientType == 3) {
                                serverId = map["client_id"] as? String
                            }
                        }
                    }
                } catch (e: Exception) {
                    println("${e.toString()}")
                }
            }
        }
        // projectDir in app/build.gradle.kts is android/app/, so ../../ gets to Flutter root
        val flutterRoot = File(projectDir.parentFile.parentFile, "lib/generated")
        flutterRoot.mkdirs()
        val out = File(flutterRoot, "server_client_id.dart")
        out.writeText("const String kServerClientId = ${if (serverId != null) "\"$serverId\"" else "\"\""};\n")
    }
}

tasks.named("preBuild") {
    dependsOn("generateServerClientId")
}
