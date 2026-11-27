#!/bin/bash
cd "$HOME/armbian-build"
echo "===== 'build' subcommand def in commands.sh ====="
grep -n '"build"\|build=\|BUILD_SUBCMD\|cli_build\|function.*build' lib/functions/cli/commands.sh | head
echo "===== docker requirement / host build decision ====="
grep -rn "docker" lib/functions/cli/entrypoint.sh lib/functions/cli/commands.sh 2>/dev/null | head -20
echo "===== search DOCKER default / host flag across lib ====="
grep -rn "DOCKER=\|declare.*DOCKER\|-z.*DOCKER\|DOCKER:-no\|DOCKER:-yes\|host.*build\|build_on_host" lib/functions/configuration/ lib/functions/cli/ lib/functions/host/ 2>/dev/null | head -25
echo "===== requirements: what does build check (docker?) ====="
sed -n '1,60p' lib/functions/cli/cli-requirements.sh
echo "===== DONE_HELP2 ====="
