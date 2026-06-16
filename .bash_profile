# .bash_profile — Perplexity Clojure Space
# Sourced by SETUP.sh and at shell login.
# SPACE and THREAD are set by the agent each turn.

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java 2>/dev/null) 2>/dev/null)) 2>/dev/null || echo "")
export PATH="$JAVA_HOME/bin:/usr/local/bin:$PATH"
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/tmp"
export CLJ_CONFIG="$HOME/.clojure"
export PNPM_HOME="/usr/local/bin"

# Sandbox TTL sentinel — compare against sandbox.edn on load
export SANDBOX_START_EPOCH=$(date +%s)
