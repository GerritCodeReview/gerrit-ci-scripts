#!/bin/bash -e

export ANDROID_HOME=~/android-sdk

if [ ! -f "$ANDROID_HOME/licenses/android-sdk-license" ]; then
    # See https://developer.android.com/studio/intro/update.html#download-with-gradle.
    echo "Exporting an Android SDK license..."
    mkdir -p $ANDROID_HOME/licenses
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
fi

# Work around https://code.google.com/p/android/issues/detail?id=223424.
mkdir -p ~/.android

./gradlew assemble
