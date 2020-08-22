{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, glog
, libedgetpu
, tensorflow-lite
, abseil-cpp
, flatbuffers
}:
stdenv.mkDerivation {
  pname = "libedgetpu-basic-engine";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    libedgetpu.basic.engine-native
    libedgetpu.dev
    tensorflow-lite
    abseil-cpp
    glog
    flatbuffers
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -g \
      -std=c++11 \
      -shared \
      -o libedgetpu_basic_engine.so \
      -ledgetpu_basic_engine_native \
      $PWD/src/cpp/basic/basic_engine.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/basic,lib}

    cp libedgetpu_basic_engine.so $out/lib
    cp src/cpp/basic/basic_engine.h $out/include/src/cpp/basic

  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
