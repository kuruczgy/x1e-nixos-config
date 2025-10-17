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
  version = "200.0.43.0";
  commit = "334c1647c990e45b242c07cb81af13db8d1cef2b";

  qcdx8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/qcdx8380.cab";
    hash = "sha256-Vz2wrKDIV6yJZYsdY7JJHCwTadg/ezhdJ6s/9DwIzHE=";
  };

  adsp8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/surfacepro_ext_adsp8380.cab";
    hash = "sha256-jj8MziLDNBMP5bs1um1vjgKUDxrFFV1xQqsb3Lsduyc=";
  };

  cdsp8380 = fetchurl {
    url = "https://raw.githubusercontent.com/WOA-Project/Qualcomm-Reference-Drivers/${finalAttrs.commit}/Surface/8380_DEN/${finalAttrs.version}/qcnspmcdm_ext_cdsp8380.cab";
    hash = "sha256-ifjtFDaXraUFJ8NKhi+v2/ww9Mc9FSuZFs8SMM6IaeM=";
  };

  board-2 = "${linux-firmware}/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin";

  bdencoder = fetchurl {
    url = "https://raw.githubusercontent.com/qca/qca-swiss-army-knife/34ba9a417a589d62851a1522978d1e1bc0f2db86/tools/scripts/ath12k/ath12k-bdencoder";
    hash = "sha256-/cyNyWKNZ+UA1Jah3iLoLhNt3q7DJmnqGzrdk/KYBlI=";
  };

  nativeBuildInputs = [
    cabextract
    rsync
    python3
  ];

  buildCommand = ''
    mkdir -p $out/lib/firmware/{qcom/x1e80100/microsoft/Denali,ath12k/WCN7850/hw2.0}

    python3 ${finalAttrs.bdencoder} --extract ${finalAttrs.board-2}
    mv "bus=pci,vendor=17cb,device=1107,subsystem-vendor=17cb,subsystem-device=3378,qmi-chip-id=2,qmi-board-id=255.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/board.bin

    find "$out" -exec touch --date=2000-01-01 {} +
  '';
})
