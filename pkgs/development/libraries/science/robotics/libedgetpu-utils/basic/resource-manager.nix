{ stdenv
, autoPatchelfHook
, fetchFromGitHub
, abseil-cpp
, glog
, libedgetpu
, tensorflow-lite
}:
stdenv.mkDerivation {
  pname = "libedgetpu-resource-manager";
  version = "eel2";

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc.lib ];
  buildInputs = [
    abseil-cpp
    glog
    libedgetpu.dev
    libedgetpu.utils.error-reporter
    tensorflow-lite
  ];

  buildPhase = ''
    $CXX \
      -I $PWD \
      -fPIC \
      -shared \
      -g \
      -std=c++11 \
      -o libedgetpu_resource_manager.so \
      -ledgetpu_error_reporter \
      -lglog \
      -Wl,--whole-archive \
      -labsl_synchronization \
      -labsl_malloc_internal \
      -labsl_raw_logging_internal \
      -labsl_time \
      -labsl_time_zone \
      -labsl_int128 \
      -labsl_stacktrace \
      -labsl_spinlock_wait \
      -labsl_debugging_internal \
      -labsl_demangle_internal \
      -labsl_symbolize \
      -labsl_dynamic_annotations \
      -labsl_base \
      -Wl,--no-whole-archive \
      $PWD/src/cpp/basic/edgetpu_resource_manager.cc
  '';

  installPhase = ''
    mkdir -p $out/{include/src/cpp/basic,lib}

    cp libedgetpu_resource_manager.so $out/lib
    cp src/cpp/basic/edgetpu_resource_manager.h $out/include/src/cpp/basic
  '';

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = "edgetpu";
    rev = "eel2";
    sha256 = "1ipzirrdqi1h3zmzz23662dlw6czzjz6iya8v7923gc4i1lz0wwm";
  };
}
