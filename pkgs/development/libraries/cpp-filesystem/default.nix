{ lib, stdenv, fetchFromGitHub, cmake, gtest }:
let
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "gulrak";
    repo = "filesystem";
    rev = "v${version}";
    sha256 = "15vgiijl3frc697c5w7852r2qj5ks4x6z8r9qyhg625bl3smjw5a";
  };
in
stdenv.mkDerivation {
  pname = "filesystem";
  inherit version src;

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DGHC_FILESYSTEM_BUILD_TESTING=ON"
    "-DGHC_FILESYSTEM_WITH_INSTALL=ON"
    "-DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF"
  ];

  doCheck = true;
  checkInputs = [ gtest ];

  meta = with lib; {
    description = "Basic tools (containers, algorithms) used by other quantstack packages";
    homepage = "https://github.com/xtensor-stack/xtl";
    license = licenses.bsd3;
    maintainers = with maintainers; [ cpcloud ];
    platforms = platforms.all;
  };
}
