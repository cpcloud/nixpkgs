{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
, flatbuffers
}:
stdenv.mkDerivation {
  pname = "libedgetpu-posenet-decoder";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    flatbuffers
    tensorflow-lite
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -g \
      -shared \
      -std=c++11 \
      -o libedgetpu_posenet_decoder.so \
      $PWD/src/cpp/posenet/posenet_decoder.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/posenet,lib}

    cp libedgetpu_posenet_decoder.so $out/lib
    cp src/cpp/posenet/posenet_decoder.h $out/include/src/cpp/posenet
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
