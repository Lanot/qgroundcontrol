!/bin//bash

BUILD_TYPE="Release"
#BUILD_TYPE="Debug"

QT_VERSION="6.10.3"

rm -rf build
rm -rf CMakeCache.txt

$QT_PATH/bin/qt-cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=$BUILD_TYPE
cmake --build build --config $BUILD_TYPE

echo "BUILT EXECUTABLE:"
ls -la ./build/$BUILD_TYPE/QGroundControl
