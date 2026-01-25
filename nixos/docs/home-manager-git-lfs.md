# Home-manager with dotfiles from GitHub (with git-lfs)

Use `pkgs.fetchgit` with `fetchLFS = true` instead of `fetchFromGitHub` - the latter doesn't support LFS. Must use commit hash not branch name for `rev` parameter.

```nix
dotfiles = pkgs.fetchgit {
  url = "https://github.com/user/repo.git";
  rev = "commit-hash";
  sha256 = "...";
  fetchLFS = true;
};
```

Src: https://discourse.nixos.org/t/how-to-use-git-lfs-with-fetchgit/55975
