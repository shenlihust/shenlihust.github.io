#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# Prefer the project's Homebrew Ruby without changing the system Ruby.
if [ -x /opt/homebrew/opt/ruby@3.4/bin/ruby ]; then
  export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"
fi

bundle check || bundle install
echo "博客预览：http://127.0.0.1:4000（按 Ctrl+C 停止）"
exec bundle exec jekyll serve --host 127.0.0.1 --port 4000
