set -x
set -e
git update-index --skip-worktree ./config.txt
git fetch
git pull
