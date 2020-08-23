{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, flatbuffers
, libedgetpu
}:
stdenv.mkDerivation {
  pname = "libedgetpu-posenet-decoder-tflite-plugin";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    flatbuffers
    tensorflow-lite
    libedgetpu.posenet.decoder-op
  ];

  patches = [ ./include-memory.patch ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -g \
      -shared \
      -std=c++11 \
      -o libedgetpu_posenet_decoder_tflite_plugin.so \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -Wl,--no-whole-archive \
      -ledgetpu_posenet_decoder_op \
      $PWD/src/cpp/posenet/posenet_decoder_tflite_plugin.cc
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libedgetpu_posenet_decoder_tflite_plugin.so $out/lib
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
