{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, flatbuffers
, glog
, libedgetpu
}:
stdenv.mkDerivation {
  pname = "libedgetpu-tflite-graph-util";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    libedgetpu.utils.utils
    tensorflow-lite
    glog
    flatbuffers
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -shared \
      -g \
      -std=c++11 \
      -o libedgetpu_tflite_graph_util.so \
      -ledgetpu_utils \
      -lglog \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -Wl,--no-whole-archive \
      $PWD/src/cpp/tools/tflite_graph_util.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/tools,lib}

    cp libedgetpu_tflite_graph_util.so $out/lib
    cp src/cpp/tools/tflite_graph_util.h $out/include/src/cpp/tools

  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
