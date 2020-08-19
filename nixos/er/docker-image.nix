{ config, pkgs, ... }:
{
  options.er.images.docker = {
  };

  config = {
    ec2.hvm = true;
    services.vector.enable = true;
  };
}
