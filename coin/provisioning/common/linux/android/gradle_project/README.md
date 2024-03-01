# Android Gradle Project for COIN

This project is used to at provisioning time to do an Android Gradle build that
will download Gradle binaries and AGP dependencies, then they will be cached
allowing consecutive builds, i.e. at test runs to not redownload the Gradle
binaries which tend to run into network issues and thus improving the
reliability of the Android integrations on COIN.

The project is a basic empty views Android project that can be created by
Android Studio, it's Java based. Below is some extra details on relevant files
that might need updates in the future:

- settings.gradle: mainly sets the the project name
- under app/src/main/ res/layout/activity_main.xml and src/*/*.java: sets the
    layout and logic of the app, this shouldn't need to be touched.
- AndroidManifest.xml / app/build.gradle: Sets project settings like target version.
- gradle/libs.versions.toml: This sets the version numbers of various dependencies.

Other files required for the project build are gradle wrapper and scripts which
are fetched by android_linux.sh from qtbase.
