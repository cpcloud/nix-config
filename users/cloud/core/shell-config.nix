{ config, pkgs, ... }: {
  historySize = 100000000;

  shellAliases = rec {
    cb = "cargo build";
    cbr = "cargo build --release";
    cch = "cargo check";
    ccl = "cargo clippy";
    cdr = "cd $(git root)";
    cr = "cargo run";
    crr = "cargo run --release";
    ct = "cargo test";
    ctr = "cargo test --release";
    dc = "docker-compose";
    gap = "git add --patch";
    gbD = "git branch --delete --force";
    gb = "git branch -vv";
    gcb = "git branch --show-current";
    gc = "git commit";
    gck = "git commit --all --message 'chore: checkpoint'";
    gcob = "git checkout --no-track -b"; # don't automatically track base ref
    gcp = "git cherry-pick";
    gcpa = "git cherry-pick --abort";
    gcpc = "git cherry-pick --continue";
    gdc = "git diff --cached";
    gfa = "git fetch --all --prune --tags";
    gfu = "git commit --fixup HEAD";
    gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    glp = "${gl} --stat --patch";
    glp1 = "${glp} HEAD~1..";
    glst = "${gl} --stat";
    glst1 = "${glst} --max-count=1";
    gm = "git merge";
    gma = "git merge --abort";
    gmain = "git symbolic-ref refs/remotes/upstream/HEAD | ${pkgs.sd}/bin/sd 'refs/remotes/upstream/' ''";
    gmc = "git merge --continue";
    gp = "git push";
    gpl = "git pull";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";
    grb = "git rebase";
    grbi = "git rebase --interactive";
    gr = "git remote --verbose";
    grh = "git commit --reuse-message HEAD --amend";
    grsh = "git reset --hard";
    grsl = "git undo --soft 1";
    gsl = "git shortlog --summary --numbered --no-merges";
    gstd = "git stash drop";
    gst = "git stash";
    gstp = "git stash pop";
    gt = "git tag";
    nsh = "nix-shell --command zsh";
    ping = "${pkgs.prettyping}/bin/prettyping";
    zs = "source $HOME/${config.programs.zsh.dotDir}/.zshrc";
    ls = "${pkgs.exa}/bin/exa --header --long --classify";
  };
}
