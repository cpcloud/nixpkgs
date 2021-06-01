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
, stdenv
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
  checkInputs = [ gtest ];
  # preCheck = ''
  #   echo $PWD
  #   ls -ltr --color /build/source/test
  #   echo "--------------------"
  #   ls -ltr --color /build/source/build/test
  #   echo "--------------------"
  #   exit 1
  # '';
  checkPhase = ''
    runHook preCheck

    pushd test
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
