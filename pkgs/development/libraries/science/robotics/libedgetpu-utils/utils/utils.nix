{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, abseil-cpp
, glog
, libedgetpu
}:
stdenv.mkDerivation {
  pname = "libedgetpu-utils";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];

  buildInputs = [
    tensorflow-lite
    abseil-cpp
    glog
    libedgetpu.utils.error-reporter
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -shared \
      -g \
      -std=c++11 \
      -o libedgetpu_utils.so \
      -ledgetpu_error_reporter \
      $PWD/src/cpp/utils.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp,lib}

    cp src/cpp/{,bbox_}utils.h $out/include/src/cpp
    cp libedgetpu_utils.so $out/lib
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
