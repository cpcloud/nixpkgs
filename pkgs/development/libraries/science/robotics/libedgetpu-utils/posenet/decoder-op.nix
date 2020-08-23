{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, flatbuffers
, libedgetpu
}:
stdenv.mkDerivation {
  pname = "libedgetpu-posenet-decoder-op";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    flatbuffers
    tensorflow-lite
    libedgetpu.posenet.decoder
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -g \
      -fPIC \
      -shared \
      -std=c++11 \
      -o libedgetpu_posenet_decoder_op.so \
      -ledgetpu_posenet_decoder \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -Wl,--no-whole-archive \
      $PWD/src/cpp/posenet/posenet_decoder_op.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/posenet,lib}

    cp libedgetpu_posenet_decoder_op.so $out/lib
    cp src/cpp/posenet/posenet_decoder_op.h $out/include/src/cpp/posenet
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
