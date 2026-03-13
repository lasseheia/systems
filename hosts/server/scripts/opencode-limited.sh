exec @SYSTEMD@/bin/systemd-run \
  --user \
  --scope \
  --collect \
  --quiet \
  -p CPUQuota=150% \
  @COREUTILS@/bin/nice -n 10 @OPENCODE@/bin/opencode "$@"
