{ stdenv
, bash
, eigen
, fetchFromGitHub
, fetchFromGitLab
, fetchpatch
, fetchurl
, flatbuffers
, gnumake
, hostPlatform
, lib
, zlib
, abseil-cpp
}:
let
  tensorflow-commit = "c738e60e3dbbf2a86fe38a753ba6d8d1d1a196ec";

  tflite-eigen = eigen.overrideAttrs (attrs: {
    version = "3.3.90";
    src = fetchFromGitLab {
      owner = "libeigen";
      repo = "eigen";
      rev = "52a2fbbb008a47c5e3fb8ac1c65c2feecb0c511c";
      sha256 = "115nr2mj3g9q492qs79c9yrlnn5f4f236rqw7dsxp5q2x8j6fki6";
    };
    patches = [
      ./eigen_include_dir.patch
      (
        fetchpatch {
          url = "https://raw.githubusercontent.com/tensorflow/tensorflow/${tensorflow-commit}/third_party/eigen3/gpu_packet_math.patch";
          sha256 = "08aqlvhg25vv7pp5drdwgmm6b3zw8x1f66kxxfq7pky9lwh2g36r";
        }
      )
    ];
  });

  gemmlowp-src = fetchFromGitHub {
    owner = "google";
    repo = "gemmlowp";
    rev = "12fed0cd7cfcd9e169bf1925bc3a7a58725fdcc3";
    sha256 = "1a27h0yay00ppjr7cm5lhpydd66a4c7phihhgiw1zsygaxkl2gy1";
  };

  neon-2-sse-src = fetchFromGitHub {
    owner = "intel";
    repo = "ARM_NEON_2_x86_SSE";
    rev = "1200fe90bb174a6224a525ee60148671a786a71f";
    sha256 = "0fhxch711ck809dpq1myxz63jiiwfcnxvj45ww0kg8s0pqpn5kv6";
  };

  farmhash-src = fetchFromGitHub {
    owner = "google";
    repo = "farmhash";
    rev = "816a4ae622e964763ca0862d9dbd19324a1eaf45";
    sha256 = "1mqxsljq476n1hb8ilkrpb39yz3ip2hnc7rhzszz4sri8ma7qzp6";
  };

  fft2d-src = fetchurl {
    url = "http://www.kurims.kyoto-u.ac.jp/~ooura/fft2d.tgz";
    sha256 = "ada7e99087c4ed477bfdf11413f2ba8db8a840ba9bbf8ac94f4f3972e2a7cec9";
  };

  fp16-src = fetchFromGitHub {
    owner = "Maratyszcza";
    repo = "FP16";
    rev = "febbb1c163726b5db24bed55cc9dc42529068997";
    sha256 = "1ayrddk2zdkpzixvrlkvn4az2kx5jnivxhvffr8177yxjslrmbfw";
  };
in
stdenv.mkDerivation {
  pname = "tensorflow-lite";
  version = "v2.3.0";

  src = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    rev = tensorflow-commit;
    sha256 = "0jfw0ad26gbsbqy4f4sjkkw1fjcclbm518bsnj8379xkzdrhwr5z";
  };

  buildInputs = [ zlib flatbuffers ];

  dontConfigure = true;

  postPatch = ''
    substituteInPlace ./tensorflow/lite/tools/make/Makefile \
      --replace /bin/bash ${bash}/bin/bash \
      --replace /bin/sh ${bash}/bin/sh
  '';

  buildPhase = ''
    pushd ./tensorflow/lite/tools/make

    mkdir -p ./downloads
    pushd ./downloads

    tar xzf ${fft2d-src} -C .

    # enter the vendoring lair of doom
    ln -s ${gemmlowp-src} ./gemmlowp
    ln -s ${neon-2-sse-src} ./neon_2_sse
    ln -s ${farmhash-src} ./farmhash

    # tensorflow lite is using the *source* of flatbuffers
    ln -s ${flatbuffers.src} ./flatbuffers

    ln -s ${fp16-src} ./fp16

    # tensorflow lite expects to compile abseil into libtensorflow-lite.a
    ln -s ${abseil-cpp.src} ./absl

    # custom eigen, because why not?
    ln -s ${tflite-eigen}/include/eigen3 ./eigen

    popd
    popd

    includes="\
      -I $PWD \
      -I $PWD/tensorflow/lite/tools/make/downloads/neon_2_sse \
      -I $PWD/tensorflow/lite/tools/make/downloads/gemmlowp \
      -I $PWD/tensorflow/lite/tools/make/downloads/absl \
      -I $PWD/tensorflow/lite/tools/make/downloads/fp16/include \
      -I $PWD/tensorflow/lite/tools/make/downloads/farmhash/src \
      -I $PWD/tensorflow/lite/tools/make/downloads/eigen"

    ${gnumake}/bin/make \
      -j $NIX_BUILD_CORES \
      -f $PWD/tensorflow/lite/tools/make/Makefile \
      INCLUDES="$includes" \
      TARGET_TOOLCHAIN_PREFIX="" \
      all
  '';
  installPhase = ''
    mkdir "$out"

    # copy the static lib and binaries into the output dir
    cp -r ./tensorflow/lite/tools/make/gen/linux_${hostPlatform.uname.processor}/{bin,lib} "$out"

    # copy headers into the output dir
    find ./tensorflow/lite -type f -name '*.h'| while read f; do
      chmod -x "$f"
      install -D "$f" "$out/include/''${f/.\//}"
    done
  '';

  meta = {
    description = "An open source deep learning framework for on-device inference.";
    homepage = "https://www.tensorflow.org/lite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
