{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, flatbuffers
, glog
, libedgetpu
, abseil-cpp
}:
stdenv.mkDerivation {
  pname = "libedgetpu-tflite-graph-util";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    libedgetpu.tools.tflite-graph-util
    tensorflow-lite
    abseil-cpp
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -g \
      -std=c++11 \
      -o join_tflite_models \
      -ledgetpu_tflite_graph_util \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -labsl_synchronization \
      -labsl_flags \
      -labsl_flags_registry \
      -labsl_flags_usage \
      -labsl_flags_usage_internal \
      -labsl_flags_parse \
      -labsl_flags_marshalling \
      -labsl_flags_program_name \
      -labsl_flags_config \
      -labsl_flags_internal \
      -labsl_symbolize \
      -labsl_stacktrace \
      -labsl_debugging_internal \
      -labsl_demangle_internal \
      -Wl,--no-whole-archive \
      -lpthread \
      -ldl \
      $PWD/src/cpp/tools/join_tflite_models.cc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./join_tflite_models $out/bin

  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
