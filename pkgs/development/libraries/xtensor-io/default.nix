{ c-blosc
, cmake
, cpp-filesystem
, crc32c
, curl
, fetchFromGitHub
, gdal
, google-cloud-cpp
, gtest
, hdf5
, highfive
, lib
, libsndfile
, openexr
, openimageio
, openimageio2
, python3
, stdenv
, writeText
, xtensor
, zlib
}:
let
  version = "0.12.8";

  src = fetchFromGitHub {
    owner = "xtensor-stack";
    repo = "xtensor-io";
    rev = version;
    sha256 = "0wnmqazdpxwz4jlp784hzqqw3xlxi320fwfblljp8mv7g92sfxs2";
  };
  python3Env = python3.withPackages (p: with p; [ numpy ]);
  genZlibTestData = writeText "gen_zlib_test_data.py" ''
    import numpy as np
    import zlib

    data = np.array([3, 2, 1, 0], dtype="float64")
    compressed = zlib.compress(data.tobytes(), level=1)

    with open("files/test.zl", "wb") as f:
        f.write(compressed)
  '';
in
stdenv.mkDerivation {
  pname = "xtensor-io";
  inherit version src;

  patches = [
    ./dump-mode-namespace.patch
    ./test-dependencies.patch
  ];

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    c-blosc
    cpp-filesystem
    crc32c
    curl
    gdal
    google-cloud-cpp
    hdf5
    highfive
    libsndfile
    openexr
    openimageio2
    xtensor
    zlib
  ];

  cmakeFlags = [
    "-DHAVE_OIIO=ON"
    "-DHAVE_SndFile=ON"
    "-DHAVE_ZLIB=ON"
    "-DHAVE_HighFive=ON"
    "-DHAVE_Blosc=ON"
    "-DHAVE_GDAL=ON"
    "-DHAVE_storage_client=ON"
    # For some reason the awssdk cannot be found by xtensor-io
    "-DHAVE_AWSSDK=OFF"
    "-DBUILD_TESTS=ON"
  ];

  doCheck = true;
  checkInputs = [ gtest python3Env ];
  checkPhase = ''
    runHook preCheck

    pushd test

    # this is needed for test_xio_zlib.cpp:xzlib.load
    python "${genZlibTestData}"

    ./test_xtensor_io_ho
    ./test_xtensor_io_lib --gtest_filter="-xio_gcs_handler.read:xio_gdal_handler.read_vsigs:xio_gdal_handler.read_vsicurl"
    popd

    runHook postCheck
  '';

  meta = with lib; {
    description = "Reading and writing image, sound and npz file formats to and from xtensor data structures.";
    homepage = "https://github.com/xtensor-stack/xtensor-io";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cpcloud ];
    platforms = platforms.all;
  };
}
