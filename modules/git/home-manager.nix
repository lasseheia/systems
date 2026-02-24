{
  programs = {
    git = {
      enable = true;
      includes = [
        {
          condition = "hasconfig:remote.*.url:https://github.com/**";
          contents.user.email = "23742718+lasseheia@users.noreply.github.com";
        }
        {
          condition = "hasconfig:remote.*.url:git@github.com:**";
          contents.user.email = "23742718+lasseheia@users.noreply.github.com";
        }
        {
          condition = "hasconfig:remote.*.url:ssh://git@github.com/**";
          contents.user.email = "23742718+lasseheia@users.noreply.github.com";
        }
        {
          condition = "hasconfig:remote.*.url:https://gitlab.com/**";
          contents.user.email = "32639578-lasseheia@users.noreply.gitlab.com";
        }
        {
          condition = "hasconfig:remote.*.url:git@gitlab.com:**";
          contents.user.email = "32639578-lasseheia@users.noreply.gitlab.com";
        }
        {
          condition = "hasconfig:remote.*.url:ssh://git@gitlab.com/**";
          contents.user.email = "32639578-lasseheia@users.noreply.gitlab.com";
        }
      ];
      settings = {
        user = {
          name = "Lasse Heia";
          email = "32639578-lasseheia@users.noreply.gitlab.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };
        pull.rebase = true;
        rebase.autoStash = true;
        commit.gpgsign = true;
        commit.verbose = true;
        gpg.format = "ssh";
        rerere.enabled = true;
        column.ui = "auto";
        branch.sort = "-committerdate";
        core = {
          pager = "bat";
          untrackedcache = true;
          fsmonitor = true;
          ignorecase = false;
        };
        maintenance.auto = true;
        push.autoSetupRemote = true;
      };
    };

    gh = {
      enable = true;
      settings = {
        version = 1;
      };
    };

    # Workaround for https://github.com/NixOS/nixpkgs/issues/169115
    gh.gitCredentialHelper.enable = false;
    git.settings.credential = {
      "https://github.com" = {
        helper = "!gh auth git-credential";
      };
      "https://gist.github.com" = {
        helper = "!gh auth git-credential";
      };
    };
  };
}
