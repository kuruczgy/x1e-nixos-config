{ pkgs, runCommand }:

runCommand "x1e80100-lenovo-yoga-slim7x-firmware-json"
{
  # The userspace pd-mapper daemon cannot handle zstd compressed firmware, so
  # let's just disable compression for these files.
  passthru.compressFirmware = false;
} ''
  mkdir -p $out/lib/firmware/qcom/x1e80100/LENOVO/83ED
  cp ${pkgs.linux-firmware}/lib/firmware/qcom/x1e80100/*.jsn \
    $out/lib/firmware/qcom/x1e80100/LENOVO/83ED/
''
