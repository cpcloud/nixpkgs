{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, abseil-cpp
, flatbuffers
, glog
, libedgetpu
}:
stdenv.mkDerivation {
  pname = "libedgetpu-basic-engine-native";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    libedgetpu.basic.resource-manager
    libedgetpu.utils.error-reporter
    libedgetpu.posenet.decoder-op
    libedgetpu.dev
    tensorflow-lite
    abseil-cpp
    flatbuffers
    glog
  ];

  buildPhase = ''
    $CXX \
      -fPIC \
      -shared \
      -g \
      -I $PWD \
      -std=c++11 \
      -o libedgetpu_basic_engine_native.so \
      -ledgetpu_resource_manager \
      -ledgetpu_error_reporter \
      -ledgetpu_posenet_decoder_op \
      -lglog \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -Wl,--no-whole-archive \
      $PWD/src/cpp/basic/basic_engine_native.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/basic,lib}
    cp libedgetpu_basic_engine_native.so $out/lib
    cp src/cpp/basic/basic_engine_native.h $out/include/src/cpp/basic

  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
