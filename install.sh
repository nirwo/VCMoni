#!/usr/bin/env bash
# End-to-end setup script for VCMoni (Linux/macOS).
# Usage:  bash install.sh
set -euo pipefail

# 1. Python virtual environment
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# 2. Front-end build
pushd frontend >/dev/null
npm install
npm run build
popd >/dev/null

# 3. Copy built assets to backend static folder
rm -rf static
mkdir -p static
cp -r frontend/dist/* static/

cat <<EOF
✅ Installation complete.
Activate environment with:
  source .venv/bin/activate
Then start the server with:
  ./start.sh (Linux/macOS) or start.bat / start.ps1 (Windows)
EOF
