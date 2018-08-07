#!/bin/bash
set -e

# MIT License
# 
# Copyright (c) 2018 John Sayo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################
@e() {
  echo "# $*"
}

@err() {
  local MSG="$*"
  echo "# Error: $MSG"
  exit 1
}
@version_lt(){
  test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1";
}
@ver() { 
  local fv=$($1 -v >/dev/null 2>&1 || $1 --version >/dev/null 2>&1 || 0)
  echo $($fv | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/')
}
@notexists() {
  [[ ! -x "$(command -v $1)" ]] 
}
@install() {
  DEBIAN_FRONTEND=noninteractive apt -yq install $1
}
@ppa() {
  DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:$1
  apt update
}
@remove() {
  DEBIAN_FRONTEND=noninteractive apt -yq purge --auto-remove $1
  rm -rf $2
}
@clearstate(){
  rm ~/.local/share/eosio/nodeos/data/blocks/* -r
  rm ~/.local/share/eosio/nodeos/data/state/* -r
}

[[ $EUID -ne 0 ]] && @err "This script must be ran as root or sudo"
[[ $(uname) != "Linux" ]] && @err "This script is only intented for Linux systems, your system is $uname"

OS_NAME=$( cat /etc/os-release | grep ^NAME | cut -d'=' -f2 | sed 's/\"//gI' )
OS_VER=$( cat /etc/os-release | grep ^VERSION_ID | cut -d'=' -f2 | sed 's/\"//gI' )

[[ $OS_NAME != "Ubuntu" ]] && @err "This script is only intented for Ubuntu 16.04, your OS is $OS_NAME $OS_VER"
[[ $OS_VER != "16.04" ]] && @err "This script is only intented for Ubuntu 16.04, your OS is $OS_NAME $OS_VER"

@e "Updating Apt cache"
# apt update

@e "Installing curl"
@install 'curl'

@e "Checking Git Installation"
GITVER=$(@ver "git")

if @notexists 'git' || @version_lt $GITVER '1.9'; then
  @e "Git Installation..."
  @install 'git'
fi

@e "Checking Cmake Installation"
CMAKEVER=$(@ver "cmake")

if @notexists 'cmake'; then
  @e "Cmake Installation"
  @ppa 'george-edison55/cmake-3.x'
  @install 'cmake'
elif @version_lt $CMAKEVER '3.4.3'; then
  @e "Removing old Cmake Installation"
  @remove 'cmake' '/usr/local/bin/cmake'
  @e "Cmake Installation"
  @ppa 'george-edison55/cmake-3.x'
  @install 'cmake'
fi


@e "Nodejs Installation"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
@install 'nodejs'
@install 'build-essential'


@e "Requirement Installation Complete"
@e "EOSIO Installation..."
sleep 3

cd ~ && git clone https://github.com/EOSIO/eos --recursive
cd ~/eos && ./eosio_build.sh
cd ~/eos && sudo ./eosio_install.sh

[[ -x "$(command -v nodeos)" ]] && @e "Successfully installed nodeos"

sleep 3

@e "EOS Initial Configuration"

cd ~ && wget https://eosnodes.privex.io/static/genesis.json
timeout 5s nodeos --genesis-json genesis.json

@e "Backing up config.ini"
mv ~/.local/share/eosio/nodeos/config/config.ini ~/.local/share/eosio/nodeos/config/config.ini.bak

@e "Adding configuration"

NODEIP=$(curl icanhazip.com || curl ifconfig.io ||curl ifconfig.co)

tee ~/.local/share/eosio/nodeos/config/config.ini <<EOF >/dev/null
get-transactions-time-limit = 3
blocks-dir = "blocks"
http-server-address = 0.0.0.0:8888
p2p-listen-endpoint = 0.0.0.0:9876
p2p-server-address = $NODEIP:9876
chain-state-db-size-mb = 16384
p2p-max-nodes-per-host = 100
http-validate-host = false
verbose-http-errors = true
access-control-allow-origin = *

allowed-connection = any

log-level-net-plugin = info
max-clients = 200
connection-cleanup-period = 60
network-version-match = 1
sync-fetch-span = 2000
enable-stale-production = false

max-implicit-request = 1500
pause-on-startup = false
max-transaction-time = 60
max-irreversible-block-age = -1
txn-reference-block-lag = 0
unlock-timeout = 90000

mongodb-queue-size = 256

plugin = eosio::chain_api_plugin
plugin = eosio::history_plugin
plugin = eosio::history_api_plugin
plugin = eosio::chain_plugin
plugin = eosio::http_plugin
plugin = eosio::wallet_plugin
plugin = eosio::db_size_api_plugin

agent-name = "Agent"

p2p-peer-address = 106.10.42.238:9876
p2p-peer-address = 159.65.214.150:9876
p2p-peer-address = bp.cryptolions.io:9876
p2p-peer-address = peering1.mainnet.eosasia.one:80
p2p-peer-address = peering2.mainnet.eosasia.one:80
EOF

timeout 5s nodeos || (@clearstate && timeout 5s nodeos --genesis-json genesis.json)

@e "Configuring Daemon"

cd ~ && wget https://bitslercasino.github.io/tutorials/static/nodeosd 
chmod +x nodeosd && sudo ln -s ~/nodeosd /usr/local/bin/


@e "Installation Complete!"
@e "To start nodeos: 'nodeosd start'"
@e "To stop nodeos: 'nodeosd stop'"
@e "To check nodeos status: 'nodeosd status'"
@e "To view nodeos logs: 'nodeos logs'"

@e "Enjoy!"