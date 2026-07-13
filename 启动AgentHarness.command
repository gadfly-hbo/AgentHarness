#!/bin/zsh -f
# AgentHarness 一键启动 — 双击运行
# 启动 DataBase Console(:8788)，就绪后自动打开浏览器；关闭本窗口即停止服务。

cd "$(dirname "$0")" || exit 1

APP_NAME="AgentHarness"
WEB_URL="http://127.0.0.1:8788"
HEALTH_URL="http://127.0.0.1:8788/api/schema"

is_ready() {
  curl -fsS -o /dev/null "$HEALTH_URL" 2>/dev/null
}

open_browser() {
  if open -a "Google Chrome" --fresh "$WEB_URL" 2>/dev/null; then
    return 0
  fi
  open "$WEB_URL"
}

kill_port_listeners() {
  lsof -ti "tcp:$1" 2>/dev/null | xargs kill 2>/dev/null || true
}

if ! command -v node >/dev/null 2>&1; then
  export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.nvm/versions/node/*/bin:$PATH"
fi

if ! command -v node >/dev/null 2>&1; then
  echo "找不到 node，请确认 Node.js 已安装并在 PATH 中。"
  echo "按回车关闭..."; read; exit 1
fi

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "找不到 sqlite3，请确认 SQLite 已安装并在 PATH 中。"
  echo "按回车关闭..."; read; exit 1
fi

if [ ! -f "DataBase/agentharness.sqlite" ]; then
  echo "初始化 SQLite 数据库..."
  sqlite3 DataBase/agentharness.sqlite ".read DataBase/migrations/001_create_entities.sql" || {
    echo "数据库迁移失败"; echo "按回车关闭..."; read; exit 1;
  }
  sqlite3 DataBase/agentharness.sqlite ".read DataBase/seeds/001_seed_entities.sql" || {
    echo "数据库种子数据写入失败"; echo "按回车关闭..."; read; exit 1;
  }
fi

if is_ready; then
  echo "检测到 $APP_NAME DataBase Console 已在运行，直接打开浏览器..."
  open_browser
  exit 0
fi

kill_port_listeners 8788

echo "启动 $APP_NAME DataBase Console..."
node DataBase/console/server.mjs &
SERVER_PID=$!

cleanup() {
  echo "\n正在停止 $APP_NAME DataBase Console..."
  kill "$SERVER_PID" 2>/dev/null
  kill_port_listeners 8788
}
trap cleanup INT TERM EXIT

echo -n "等待服务就绪"
READY=0
for i in {1..30}; do
  if is_ready; then
    echo " 就绪。"
    READY=1
    open_browser
    break
  fi
  echo -n "."
  sleep 1
done

if [ "$READY" -eq 0 ]; then
  echo "\n等待超时，仍未检测到服务就绪。可稍后手动打开：$WEB_URL"
  open_browser
fi

echo "\n----------------------------------------"
echo "  $APP_NAME DataBase Console: $WEB_URL"
echo "  关闭此窗口或按 Ctrl+C 即停止服务"
echo "----------------------------------------"

wait "$SERVER_PID"
