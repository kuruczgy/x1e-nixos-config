{
  fetchFromGitHub,
  fetchurl,
  runCommand,
}:

let
  # 2025-09-01 from SpieringsAE
  firmware = fetchFromGitHub {
    owner = "anonymix007";
    repo = "x1e-firmware";
    rev = "606ba5f27d1b94469cd048dbb9d8e3c65ae9a288";
    hash = "sha256-pLgZ4/ZlvWXJaq3grCXtPgJkvCeYV+n84nYEvWd2slg=";
  };

  # TODO: below needed for better BT connection?! Switch Pro controller disconnecting super close at least...
  # 460549a801a1532d57848422a2c9833d9b638ecab5263367908ac3cde9ed647a  qca/hmtbtfw20.tlv
  # 8b889d62ba0f22d6612ed0f6534aa1399533b851c7cc171661bdba9071855e72  qca/hmtnv20.b112
  #hmtbtfw20 = fetchurl {
  #  url = "https://github.com/hogliux/yoga7x-firmware/raw/f2ce80c668f91938c67e8e5196a777fcc905d9d3/firmware/qca/hmtbtfw20.tlv";
  #  hash = "sha256-RgVJqAGhUy1XhIQiosmDPZtjjsq1JjNnkIrDzentZHo=";
  #};
  #hmtnv20 = fetchurl {
  #  url = "https://github.com/hogliux/yoga7x-firmware/raw/f2ce80c668f91938c67e8e5196a777fcc905d9d3/firmware/qca/hmtnv20.b112";
  #  hash = "sha256-i4idYroPItZhLtD2U0qhOZUzuFHHzBcWYb26kHGFXnI=";
  #};
in
runCommand "x1e80100-asus-vivobook-s15-firmware" { } ''
  mkdir -p $out/lib/firmware/qcom/x1e80100/ASUSTeK/vivobook-s15
  cp ${firmware}/firmware/qcom/x1e80100/ASUSTeK/vivobook-s15/{*.elf,*.mbn,*.jsn} \
    $out/lib/firmware/qcom/x1e80100/ASUSTeK/vivobook-s15/
''
