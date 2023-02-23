{ stdenv
, lib
, fetchFromGitHub
, fixDarwinDylibNames
, aws-sdk-cpp
, bison
, boost
, bzip2
, cmake
, double-conversion
, flex
, fmt_8
, folly
, gflags
, glog
, gtest
, gmock
, libevent
, lz4
, lzo
, ninja
, openssl
, python3
, protobuf
, re2
, snappy
, zlib
, zstd
, enableShared ? !stdenv.hostPlatform.isStatic
}:

stdenv.mkDerivation rec {
  pname = "velox";
  version = "12345.0";

  src = fetchFromGitHub {
    repo = "velox";
    owner = "facebookincubator";
    rev = "92fbfb9ed5394747f93f3e2acd49b7f1a32617ef";
    hash = "sha256-uJ0zcYMDN3aSyf+TZRgaM1JJVQ32Kv1caykJgQchCjs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ] ++ lib.optional stdenv.isDarwin fixDarwinDylibNames;
  buildInputs = [
    aws-sdk-cpp
    bison
    boost
    bzip2
    double-conversion
    flex
    fmt_8
    folly
    gflags
    glog
    gmock
    gtest
    libevent
    lz4
    lzo
    openssl
    python3
    protobuf
    re2
    snappy
    zlib
    zstd
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-mavx2"
    "-mfma"
    "-mavx"
    "-mf16c"
    "-mlzcnt"
  ];

  cmakeFlags = [
    "-DVELOX_BUILD_TESTING=ON"
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DVELOX_ENABLE_S3=ON"
    "-DVELOX_ENABLE_BENCHMARKS=OFF"
    "-DVELOX_ENABLE_EXAMPLES=OFF"
    "-DVELOX_BUILD_BENCHMARKS_LARGE=OFF"
    "-DAWSSDK_CORE_HEADER_FILE=${aws-sdk-cpp}/include/aws/core/Aws.h"
  ];

  doInstallCheck = true;
  GTEST_FILTER = "";
  installCheckPhase = ''
    echo $PWD
    ls $PWD
    ctest --build-run-dir build/release -j $NIX_BUILD_CORES --output-on-failure
  '';

  meta = with lib; {
    description = "A cross-language development platform for in-memory data";
    homepage = "https://github.com/facebookincubator/velox";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ cpcloud ];
  };
}
