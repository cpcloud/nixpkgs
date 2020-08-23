{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, abseil-cpp
, libedgetpu
, tensorflow-lite
}:
stdenv.mkDerivation {
  pname = "libedgetpu-version";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];

  buildInputs = [
    abseil-cpp
    libedgetpu.dev
    tensorflow-lite
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -shared \
      -g \
      -std=c++11 \
      -o libedgetpu_version.so \
      $PWD/src/cpp/version.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp,lib}

    cp src/cpp/version.h $out/include/src/cpp
    cp libedgetpu_version.so $out/lib
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
