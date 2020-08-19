{ config, pkgs, ... }:
{
  imports = [
    ./../modules/virtualisation/amazon-image.nix
  ];

  options.er.images.docker = {
  };

  config = {
    ec2.hvm = true;
    services.vector.enable = true;
  };
}
