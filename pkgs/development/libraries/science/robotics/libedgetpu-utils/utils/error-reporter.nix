{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, tensorflow-lite
}:
stdenv.mkDerivation {
  pname = "libedgetpu-error-reporter";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];

  buildInputs = [
    tensorflow-lite
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -shared \
      -g \
      -std=c++11 \
      -o libedgetpu_error_reporter.so \
      -Wl,--whole-archive \
      -ltensorflow-lite \
      -Wl,--no-whole-archive \
      $PWD/src/cpp/error_reporter.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp,lib}

    cp src/cpp/error_reporter.h $out/include/src/cpp
    cp libedgetpu_error_reporter.so $out/lib
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
