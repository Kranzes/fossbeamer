# Machine config, specifically for raspberry cm3
{ config
, modulesPath
, pkgs
, lib
, ...
}:

let
  ubootRaspberryPiGeneric = pkgs.buildUBoot {
    defconfig = "rpi_arm64_defconfig";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "u-boot.bin" ];
  };

in
{
  imports = [ ./configuration.nix ];

  sdImage.populateFirmwareCommands = ''
    rm firmware/u-boot-rpi3.bin
    # Overwrite firmware/u-boot-rpi3.bin with the generic one
    cp ${ubootRaspberryPiGeneric}/u-boot.bin firmware/u-boot-rpi3.bin    
    # Add the .dtb for our board
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-cm3.dtb firmware/
  '';

  # u-boot doesn't know the proper device tree name, so cannot pick from FTDIR
  # on its own.
  hardware.deviceTree.name = "broadcom/bcm2837-rpi-cm3-io3.dtb";
  hardware.deviceTree.overlays = [
    {
      # http://lists.infradead.org/pipermail/linux-arm-kernel/2024-July/943386.html
      name = "fix-hdmi-hpd-gpio-port";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "raspberrypi,3-compute-module", "brcm,bcm2837";
        };
        &{/soc} {
          hdmi {
            hpd-gpios = <&expgpio 0 1>;
          };
        };
      '';
    }
  ];
}
