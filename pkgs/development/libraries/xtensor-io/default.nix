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
, openimageio2
, python3
, stdenv
, writeText
, xtensor
, zlib
}:
let
  genZlibTestData = writeText "gen_zlib_test_data.py" ''
    """Generate data necessary to run `test_xio_zlib.cpp:xzlib.load`."""

    import struct
    import sys
    import zlib

    raw_bytes = struct.pack("4d", *map(float, range(3, -1, -1)))
    compressed = zlib.compress(raw_bytes, level=1)

    with open(sys.argv[1], "wb") as f:
        f.write(compressed)
  '';
in
stdenv.mkDerivation rec {
  pname = "xtensor-io";
  version = "0.12.8";

  src = fetchFromGitHub {
    owner = "xtensor-stack";
    repo = "xtensor-io";
    rev = version;
    sha256 = "0wnmqazdpxwz4jlp784hzqqw3xlxi320fwfblljp8mv7g92sfxs2";
  };

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
    "-DHAVE_AWSSDK=OFF" # For some reason the awssdk cannot be found by xtensor-io
    "-DBUILD_TESTS=ON"
  ];

  doCheck = true;
  checkInputs = [ gtest python3 ];
  checkTarget = "xtest";
  preCheck = ''
    python "${genZlibTestData}" test/files/test.zl
  '';
  GTEST_FILTER =
    let
      filteredTests = [
        "xio_gcs_handler.read" # accesses the internet
        "xio_gdal_handler.read_vsicurl" # accesses the internet
        "xio_gdal_handler.read_vsigs" # accesses a file that doesn't exist
      ];
    in
    "-${builtins.concatStringsSep ":" filteredTests}";

  NIX_CFLAGS_COMPILE = "-pthread";

  meta = with lib; {
    description = "Reading and writing image, sound and npz file formats to and from xtensor data structures.";
    homepage = "https://github.com/xtensor-stack/xtensor-io";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cpcloud ];
    platforms = platforms.all;
  };
}
