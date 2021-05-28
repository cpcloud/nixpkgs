{ lib
, python3

, writeTextDir
, substituteAll
, fetchpatch
, installShellFiles
}:

python3.pkgs.buildPythonApplication rec {
  pname = "meson";
  version = "0.58.0";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "1p9g334xnfxpgrzdcnla7p399viny6jqrbylkw0rk74npkq0v0pl";
  };

  patches = [
    # Upstream insists on not allowing bindir and other dir options
    # outside of prefix for some reason:
    # https://github.com/mesonbuild/meson/issues/2561
    # We remove the check so multiple outputs can work sanely.
    ./allow-dirs-outside-of-prefix.patch

    # Meson is currently inspecting fewer variables than autoconf does, which
    # makes it harder for us to use setup hooks, etc.  Taken from
    # https://github.com/mesonbuild/meson/pull/6827
    ./more-env-vars.patch

    # Unlike libtool, vanilla Meson does not pass any information
    # about the path library will be installed to to g-ir-scanner,
    # breaking the GIR when path other than ${!outputLib}/lib is used.
    # We patch Meson to add a --fallback-library-path argument with
    # library install_dir to g-ir-scanner.
    ./gir-fallback-path.patch

    # In common distributions, RPATH is only needed for internal libraries so
    # meson removes everything else. With Nix, the locations of libraries
    # are not as predictable, therefore we need to keep them in the RPATH.
    # At the moment we are keeping the paths starting with /nix/store.
    # https://github.com/NixOS/nixpkgs/issues/31222#issuecomment-365811634
    (substituteAll {
      src = ./fix-rpath.patch;
      inherit (builtins) storeDir;
    })

    # When Meson removes build_rpath from DT_RUNPATH entry, it just writes
    # the shorter NUL-terminated new rpath over the old one to reduce
    # the risk of potentially breaking the ELF files.
    # But this can cause much bigger problem for Nix as it can produce
    # cut-in-half-by-\0 store path references.
    # Let’s just clear the whole rpath and hope for the best.
    ./clear-old-rpath.patch

    # Patch out default boost search paths to avoid impure builds on
    # unsandboxed non-NixOS builds, see:
    # https://github.com/NixOS/nixpkgs/issues/86131#issuecomment-711051774
    ./boost-Do-not-add-system-paths-on-nix.patch

    # Fix gtkdoc generation.
    # Should be fixed in 0.58.1.
    # https://github.com/mesonbuild/meson/pull/8757
    (fetchpatch {
      url = "https://github.com/mesonbuild/meson/commit/4e312c19e693a69b0650ce6c8a8903163c959996.patch";
      sha256 = "qO5ZE0GXlCbIROQGKFdqYQB1h9r9eW/SPZ2Gi+0KmiE=";
    })

    # Fix nested environment().
    # Should be fixed in 0.58.1.
    # https://github.com/mesonbuild/meson/pull/8761
    (fetchpatch {
      url = "https://github.com/mesonbuild/meson/commit/501d7cf01c5578e98ab753fd09f6972f57824e50.patch";
      sha256 = "8KAXuLQAItth/Pj/9ud3poothyIpYStI0S9BGRRkic8=";
    })
  ];

  setupHook = ./setup-hook.sh;

  # 0.45 update enabled tests but they are failing
  doCheck = false;
  # checkInputs = [ ninja pkg-config ];
  # checkPhase = "python ./run_project_tests.py";

  postFixup = ''
    pushd $out/bin
    # undo shell wrapper as meson tools are called with python
    for i in *; do
      mv ".$i-wrapped" "$i"
    done
    popd

    # Do not propagate Python
    rm $out/nix-support/propagated-build-inputs
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --zsh data/shell-completions/zsh/_meson
    installShellCompletion --bash data/shell-completions/bash/meson
  '';

  meta = with lib; {
    homepage = "https://mesonbuild.com";
    description = "SCons-like build system that use python as a front-end language and Ninja as a building backend";
    license = licenses.asl20;
    maintainers = with maintainers; [ jtojnar mbe ];
    platforms = platforms.all;
  };
}
