{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.nixfmt.enable = true;
  programs.prettier.enable = true;
}
