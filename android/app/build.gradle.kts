import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val requiredSigningProperties = listOf(
    "keyAlias",
    "keyPassword",
    "storeFile",
    "storePassword",
)
val missingSigningProperties = requiredSigningProperties.filter { key ->
    keystoreProperties.getProperty(key).isNullOrBlank()
}
val hasReleaseSigning = missingSigningProperties.isEmpty()
val releaseKeystoreFile = if (hasReleaseSigning) {
    rootProject.file(keystoreProperties.getProperty("storeFile"))
} else {
    null
}

if (!hasReleaseSigning) {
    logger.lifecycle(
        "Android release signing is not configured. Missing: ${missingSigningProperties.joinToString()}"
    )
}
if (hasReleaseSigning && (releaseKeystoreFile == null || !releaseKeystoreFile.isFile)) {
    throw GradleException(
        "Configured Android release keystore does not exist: ${releaseKeystoreFile?.absolutePath}"
    )
}

android {
    namespace = "com.neogamelab.neostation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseKeystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.eclipse.launcher"
        manifestPlaceholders["appName"] = "ECLIPSE"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Never fall back to the debug certificate. The release-only
            // verification task below blocks unsigned release builds.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

// Do not fail Gradle configuration for debug builds or static analysis when
// the private release key is intentionally absent. Gate the release variant
// itself so every assemble/bundle release path requires the persistent key.
val verifyReleaseSigning = tasks.register("verifyReleaseSigning") {
    doLast {
        if (!hasReleaseSigning) {
            throw GradleException(
                "Release signing is required. Configure android/key.properties with the original ECLIPSE signing certificate. Missing: ${missingSigningProperties.joinToString()}"
            )
        }
        if (releaseKeystoreFile == null || !releaseKeystoreFile.isFile) {
            throw GradleException("The configured ECLIPSE release keystore is missing.")
        }
    }
}
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(verifyReleaseSigning)
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
