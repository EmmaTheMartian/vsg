#!/usr/bin/env sh

set -e

# Download V
git clone https://github.com/vlang/v
cd v
make
sudo ./v symlink
cd ..

# Download Clockwork
git clone https://github.com/EmmaTheMartian/clockwork
# Build and install Clockwork
cd clockwork
../v/v install EmmaTheMartian.Maple
../v/v run . install
cd ..
