#!/usr/bin/env bash
# SETUP.sh — Perplexity Clojure Space · idempotent bootstrap
# Run after every detected sandbox reset; safe to re-run on a live instance.
# Installs: OpenJDK 21 · Babashka · Clojure CLI · clj-kondo · pnpm · nbb · shadow-cljs
set -euo pipefail

PNPM_VER="9.15.4"
BB_VER="1.12.196"
CLJ_KONDO_VER="2025.04.07"
CLJ_VER="1.12.0.1530"

log()  { echo "[SETUP] $*"; }
ok()   { echo "[SETUP] ✓ $*"; }
skip() { echo "[SETUP] – $* already present, skipping"; }

## ── 1. Java 21 ────────────────────────────────────────────────────────────────
if command -v java &>/dev/null; then
  skip "java ($(java -version 2>&1 | head -1))"
else
  log "Installing OpenJDK 21…"
  sudo apt-get update -qq
  sudo apt-get install -y -q openjdk-21-jdk-headless
  ok "java installed"
fi
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH="$JAVA_HOME/bin:$PATH"

## ── 2. Babashka ───────────────────────────────────────────────────────────────
if command -v bb &>/dev/null; then
  skip "bb ($(bb --version))"
else
  log "Installing Babashka v${BB_VER}…"
  curl -fsSL \
    "https://github.com/babashka/babashka/releases/download/v${BB_VER}/babashka-${BB_VER}-linux-amd64-static.tar.gz" \
    | sudo tar -xz -C /usr/local/bin bb
  ok "bb $(bb --version)"
fi

## ── 3. Clojure CLI ────────────────────────────────────────────────────────────
if command -v clojure &>/dev/null; then
  skip "clojure ($(clojure --version 2>&1 | head -1))"
else
  log "Installing Clojure CLI ${CLJ_VER}…"
  curl -fsSL "https://download.clojure.org/install/linux-install-${CLJ_VER}.sh" \
    -o /tmp/clj-install.sh
  sudo bash /tmp/clj-install.sh
  ok "clojure $(clojure --version 2>&1 | head -1)"
fi

## ── 4. clj-kondo ──────────────────────────────────────────────────────────────
if command -v clj-kondo &>/dev/null; then
  skip "clj-kondo ($(clj-kondo --version))"
else
  log "Installing clj-kondo v${CLJ_KONDO_VER}…"
  curl -fsSL \
    "https://github.com/clj-kondo/clj-kondo/releases/download/v${CLJ_KONDO_VER}/clj-kondo-${CLJ_KONDO_VER}-linux-amd64.zip" \
    -o /tmp/ck.zip
  sudo unzip -q /tmp/ck.zip -d /usr/local/bin clj-kondo
  rm /tmp/ck.zip
  ok "clj-kondo $(clj-kondo --version)"
fi

## ── 5. pnpm (standalone binary) ───────────────────────────────────────────────
# NOTE: corepack+pnpm fails on Node 20.19.5 due to ESM dynamic-import issue.
# Standalone binary from GitHub releases is the reliable path.
if command -v pnpm &>/dev/null; then
  skip "pnpm ($(pnpm --version))"
else
  log "Installing pnpm ${PNPM_VER} (standalone)…"
  curl -fsSL \
    "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VER}/pnpm-linux-x64" \
    -o /tmp/pnpm
  sudo install -m 755 /tmp/pnpm /usr/local/bin/pnpm
  rm /tmp/pnpm
  ok "pnpm $(pnpm --version)"
fi

## ── 6. nbb + shadow-cljs (global npm, requires sudo) ─────────────────────────
if ! command -v nbb &>/dev/null || ! command -v shadow-cljs &>/dev/null; then
  log "Installing nbb and shadow-cljs globally…"
  sudo npm install -g nbb shadow-cljs 2>&1 | tail -2
fi
ok "nbb $(nbb --version)"
ok "shadow-cljs present (use project-local via pnpm in production)"

## ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
echo " RUNTIME MATRIX"
echo "═══════════════════════════════════════════"
for b in java bb clojure clj-kondo pnpm nbb node; do
  ver=$($b --version 2>&1 | head -1)
  printf " %-12s  %s\n" "$b" "$ver"
done
echo "═══════════════════════════════════════════"
echo ""
echo "SETUP complete. Source .bash_profile to persist env:"
echo "  source ~/.bash_profile"

npm install -g opencode-ai
opencode -v
npm install -g @open-hax/eta-mu-cli
eta-mu -v
cp .bash_profile ~/.bash_profile
