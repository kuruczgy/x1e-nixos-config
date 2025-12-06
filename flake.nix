{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      eachSystem =
        f:
        builtins.zipAttrsWith (_: nixpkgs.lib.listToAttrs) (
          map (
            system: builtins.mapAttrs (_: nixpkgs.lib.nameValuePair system) (f system)
          ) nixpkgs.lib.systems.flakeExposed
        );
    in
    eachSystem (
      localSystem:
      let
        pkgs = nixpkgs.legacyPackages.${localSystem};
        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          programs.nixfmt.enable = true;
          settings.on-unmatched = "info";
        };
        main = import ./.;
        testNixosConfig = nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            main.nixosModule
            (
              { ... }:
              {
                fileSystems."/" = {
                  device = "tmpfs";
                  fsType = "tmpfs";
                  options = [ "mode=755" ];
                };
                boot.loader.grub.device = "nodev";

                boot.initrd.includeDefaultModules = false;
                boot.initrd.availableKernelModules = [
                  # Definitely needed for USB:
                  "usb_storage"
                  "phy_qcom_qmp_combo"
                  "phy_snps_eusb2"
                  "phy_qcom_eusb2_repeater"
                  "tcsrcc_x1e80100"

                  "i2c_hid_of"
                  "i2c_qcom_geni"
                  "dispcc-x1e80100"
                  "gpucc-x1e80100"
                  "phy_qcom_edp"
                  "panel_edp"
                  "msm"
                  "nvme"
                  "phy_qcom_qmp_pcie"

                  # Needed with the DP altmode patches
                  "ps883x"
                  "pmic_glink_altmode"
                  "qrtr"
                ];
              }
            )
          ];
        };

        installBootOption = pkgs.writeScript "installBootOption" ''
          #!${pkgs.lib.getExe pkgs.python3}

          import os
          import shutil
          from pathlib import Path
          import json

          efi_dir = "/boot"
          install_dir = os.path.join(efi_dir, "kernel_bisect")

          bootspec_root = json.loads(Path(os.getenv("BOOTSPEC")).read_text())
          bootspec = bootspec_root["org.nixos.bootspec.v1"]
          devicetree = bootspec_root["org.nixos.systemd-boot"]["devicetree"]

          os.makedirs(install_dir, exist_ok=True)
          shutil.copyfile(bootspec["initrd"], os.path.join(install_dir, "initrd"))
          shutil.copyfile(bootspec["kernel"], os.path.join(install_dir, "kernel"))
          shutil.copyfile(devicetree, os.path.join(install_dir, "devicetree"))

          BOOT_ENTRY = """title kernel_bisect
          sort-key aaa
          linux /kernel_bisect/kernel
          initrd /kernel_bisect/initrd
          options {kernel_params}
          devicetree /kernel_bisect/devicetree
          """
          Path(os.path.join(efi_dir, "loader/entries/kernel_bisect.conf")).write_text(BOOT_ENTRY.format(
            kernel_params="init=" + bootspec["init"] + " " + " ".join(bootspec["kernelParams"])
          ))
        '';

        buildAndInstallKernel = pkgs.writeShellScriptBin "buildAndInstallKernel" ''
          set -ex

          out=/tmp/impure_kernel
          rm -rf "$out"
          make -j$NIX_BUILD_CORES Image dtbs modules
          mkdir -p "$out"
          make -j$NIX_BUILD_CORES INSTALL_MOD_PATH="$out" INSTALL_MOD_STRIP=1 modules_install
          cp arch/arm64/boot/Image "$out"
          cp System.map "$out"
          mkdir -p "$out"/dtbs/qcom
          cp arch/arm64/boot/dts/qcom/x1e80100-*.dtb "$out"/dtbs/qcom

          toplevel="$(PREBUILT_KERNEL="$out" nix build --impure /home/user/repos/infra-config#nixosConfigurations.cobalt.config.system.build.toplevel --no-link --print-out-paths)"
          echo "installing $toplevel"
          sudo BOOTSPEC="$toplevel"/boot.json ${installBootOption}
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.bison
            pkgs.flex
            pkgs.perl
            pkgs.bc
            pkgs.nettools
            pkgs.openssl
            pkgs.rsync
            pkgs.gmp
            pkgs.libmpc
            pkgs.mpfr
            pkgs.elfutils
            pkgs.zstd
            pkgs.python3Minimal
            pkgs.kmod
            pkgs.hexdump
            pkgs.ncurses

            buildAndInstallKernel
          ];
        };

        packages = {
          default = (main.prebuiltKernel pkgs).kernel;
          inherit (testNixosConfig.config.system.build) toplevel;
          inherit testNixosConfig;
          inherit installBootOption;
        };

        formatter = treefmtEval.config.build.wrapper;
        checks = {
          treefmt = treefmtEval.config.build.check self;
        };
      }
    );
}
