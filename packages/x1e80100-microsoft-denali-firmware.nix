{
  python3,
  stdenv,
  cabextract,
  rsync,
  fetchurl,
  linux-firmware,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "denali-firmware";
  version = "200.0.32.0";
  commit = "30e823d85c1fb4e410a4afdf9cd2285914ee712d";

  qcdx8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/qcdx8380.cab";
    hash = "sha256-9IsNoOyNfImh0/q5tizDK1ezNuXFT5CmVImQd710p3U=";
  };

  adsp8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/surfacepro_ext_adsp8380.cab";
    hash = "sha256-Mk1eeibnGnSSfIlDiKoXb4PnZ02KpibBI1UyFB27WWA=";
  };

  cdsp8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/qcnspmcdm_ext_cdsp8380.cab";
    hash = "sha256-TuS/PPCXvbBakCq7nsRpODHyC2nj90l/V6TIxyL3Cy8=";
  };

  # TODO: if the board file is already in linux-firmware, why do we have to do
  # this extraction, why can't the kernel do it when loading it?
  board-2 = "${linux-firmware}/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin";

  bdencoder = fetchurl {
    url = "https://raw.githubusercontent.com/qca/qca-swiss-army-knife/f2164085920540f4ecbfa0b12959918c601724b6/tools/scripts/ath12k/ath12k-bdencoder";
    hash = "sha256-hzn/GVo7nZmuBpuBsEZUcf928w03cgANq+kaUlGmeYA=";
  };

  nativeBuildInputs = [
    cabextract
    python3
  ];

  buildCommand = ''
    mkdir -p $out/lib/firmware/{qcom/x1e80100/microsoft/Denali,ath12k/WCN7850/hw2.0}

    cabextract -F qcdxkmsuc8380.mbn $qcdx8380
    mv qcdxkmsuc8380.mbn $out/lib/firmware/qcom/x1e80100/microsoft/qcdxkmsuc8380.mbn

    cabextract -F adsp_dtbs.elf $adsp8380
    mv adsp_dtbs.elf $out/lib/firmware/qcom/x1e80100/microsoft/Denali/adsp_dtb.mbn

    cabextract -F cdsp_dtbs.elf $cdsp8380
    mv cdsp_dtbs.elf $out/lib/firmware/qcom/x1e80100/microsoft/Denali/cdsp_dtb.mbn

    cabextract -F qcadsp8380.mbn -d $out/lib/firmware/qcom/x1e80100/microsoft/Denali/ $adsp8380
    cabextract -F qccdsp8380.mbn -d $out/lib/firmware/qcom/x1e80100/microsoft/Denali/ $cdsp8380

    python3 ${finalAttrs.bdencoder} --extract ${finalAttrs.board-2}
    mv "bus=pci,vendor=17cb,device=1107,subsystem-vendor=17cb,subsystem-device=3378,qmi-chip-id=2,qmi-board-id=255.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/board.bin

    find "$out" -exec touch --date=2000-01-01 {} +
  '';
})
