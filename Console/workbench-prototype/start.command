#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PORT="${AGENTHARNESS_WORKBENCH_PORT:-4177}"
URL="http://127.0.0.1:${PORT}/index.html"

cd "$SCRIPT_DIR"

echo "AgentHarness Console Workbench"
echo "Directory: $SCRIPT_DIR"
echo "URL:       $URL"
echo

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT is already in use."
  echo "Opening existing service: $URL"
  open "$URL"
  echo
  echo "If this is not the Workbench, stop the process using port $PORT or run:"
  echo "AGENTHARNESS_WORKBENCH_PORT=4178 ./start.command"
  echo
  echo "Press Ctrl+C to close this window."
  while true; do sleep 3600; done
fi

echo "Starting local static server on port $PORT..."
echo "Press Ctrl+C to stop."
echo

open "$URL"
python3 -m http.server "$PORT" --bind 127.0.0.1
