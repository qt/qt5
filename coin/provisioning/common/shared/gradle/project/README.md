# Android Gradle Project for COIN

Minimal Android project used at provisioning time to pre-cache the Gradle
dependencies. This avoids network downloads during Qt builds and tests
which use `--offline`.

Caches dependencies for:
- `com.android.application`: used by Qt test/example APK builds
- `com.android.library`: used by Qt JAR builds
- `org.jetbrains.kotlin.android`: used by some Qt modules
- AndroidX: used by app builds

These files should be updated each time Qt bumps the supported Android or
Gradle versions.
