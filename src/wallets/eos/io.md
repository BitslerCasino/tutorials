---
layout: default
---


## Basic Installation and Usage of EOSIO v1.1.3 on Ubuntu 16.04
![eosio-image](https://cdn-images-1.medium.com/max/800/1*t-JGDBRk9__B2-odKWUl2A.jpeg){: .img-header }
###### NOTE: All Installation steps below have been tested on a CLEAN install of Ubuntu 16.04**

### Introduction
EOSIO is software that introduces a blockchain architecture designed to enable vertical and horizontal scaling of decentralized applications (the “EOSIO Software”). This is achieved through an operating system-like construct upon which applications can be built. The software provides accounts, authentication, databases, asynchronous communication and the scheduling of applications across multiple CPU cores and/or clusters. The resulting technology is a blockchain architecture that has the potential to scale to millions of transactions per second, eliminates user fees and allows for quick and easy deployment of decentralized applications. For more information, please read the [EOS.IO Technical White Paper](https://github.com/EOSIO/Documentation/blob/master/TechnicalWhitePaper.md).

EOSIO comes with a number of programs. The primary ones that you will use, and the ones that are covered here, are:

-   `nodeos` (node + eos = nodeos) - the core EOSIO node daemon that can be configured with plugins to run a node. Example uses are block production, dedicated API endpoints, and local development.
    
-   `cleos` (cli + eos = cleos) - command line interface to interact with the blockchain and to manage wallets
    
-   `keosd` (key + eos = keosd) - component that securely stores EOSIO keys in wallets.

### Requirements

-   Ubuntu 16.04 (Ubuntu 16.10 recommended).
    
-   A Sudo User or Root is required (Sudo user is recommended).
    
-   Nodejs version 8+ (version 10+ is recommended)
    
-   Git version 1.9+
    
-   CMake version 3.4.3+
    
-   7GB RAM free required
    
-   20GB Disk free required
    
-   Patience is required

### Installation Time
- `50-60 Minutes`(without build validation) | `90-120 Minutes`(with build validation)

### Create and Login to a Sudo User
Follow this [tutorial](../../general/createsudouser.md) on how to Create a Sudo User, then login to that user.

### Update Apt cache
```bash
sudo apt update
```

### Git Installation
```bash
sudo apt install git
```

### Cmake Installation/upgrade
Skip this step if your cmake version is above or equal to 3.4.3 by checking `cmake --version`
Remove old cmake version if it exists to avoid errors.
```bash 
sudo apt purge --auto-remove cmake
sudo rm -rf /usr/local/bin/cmake
```
Install new cmake version via ppa.
```bash
sudo add-apt-repository ppa:george-edison55/cmake-3.x
sudo apt update && sudo apt install cmake
```
Check your cmake version. `cmake --version`. If cmake version is not 3.5.x, you may need to logout of your ssh session and login again.

### Nodejs Installation
For Nodejs v10 (recommended)
```bash
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs
sudo apt install -y build-essential
```
For Nodejs v8
```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs
sudo apt install -y build-essential
```

### EOS Installation
The installation steps below assumes that you have met the requirements above.
The steps below assumes that you are cloning EOSIO on your `HOME` directory.

Getting the code source of EOS via git clone.
```bash
cd ~ && git clone https://github.com/EOSIO/eos --recursive
```
Building using Autobuild script.
```bash
cd ~/eos && ./eosio_build.sh
```
This will check your system for required dependencies, and will ask you to install them, so install them as required by choosing number `1` if asked. This process will take awhile, around `50-60 Minutes`, so again have patience.

Optional, Validation and Build test. Validating build is *optional* but **recommended** and this will also take awhile,around `40-50 Minutes`, so as always, have patience.
It may some times look like that the test is stuck or the test hanged, just wait for it as some test really takes awhile(some tests can go as long as 5-10 minutes).
```bash
~/opt/mongodb/bin/mongod -f ~/opt/mongodb/mongod.conf &
cd ~/eos/build && make test
```

EOSIO Binary Installation
```bash
cd ~/eos && sudo ./eosio_install.sh
```

Check Installation
```bash
which nodeos
```
Above code should reply with `/usr/local/bin/nodeos`

### EOS Initial Configuration
Get the genesis.json and load nodeos initially.
```bash
cd ~ && wget https://eosnodes.privex.io/static/genesis.json
nodeos --genesis-json genesis.json
```
Press `ctrl-c` once the genesis.json is loaded to exit nodeos.

Back up the original `config.ini` and create a new one. You must change the `!!CHANGE TO SERVER IP ADDRESS!!` with your server ip.
```bash
mv ~/.local/share/eosio/nodeos/config/config.ini ~/.local/share/eosio/nodeos/config/config.ini.bak
tee ~/.local/share/eosio/nodeos/config/config.ini <<EOF >/dev/null
get-transactions-time-limit = 3
blocks-dir = "blocks"
http-server-address = 0.0.0.0:8888
p2p-listen-endpoint = 0.0.0.0:9876
p2p-server-address = !!CHANGE TO SERVER IP ADDRESS!!:9876
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
```

Now run `nodeos` normally.
```bash
nodeos
```

If you get an error when running `nodeos`, clear your db/state to fix it, then run `nodeos` again with genesis
```bash
rm ~/.local/share/eosio/nodeos/data/blocks/* -r
rm ~/.local/share/eosio/nodeos/data/state/* -r
nodeos --genesis-json genesis.json
```

### EOS nodeos as a Deamon
Stop any running `nodeos` by pressing `ctrl+c` then download this simple bash file.
```bash
cd ~ && wget https://bitslercasino.github.io/tutorials/static/nodeosd 
chmod +x nodeosd && sudo ln -s ~/nodeosd /usr/local/bin/
```
To start `nodeos`:
```bash
nodeosd start
```
To stop `nodeos`:
```bash
nodeosd stop
```
To check `nodeos` status:
```bash
nodeosd status
```
To view `nodeos` logs:
```bash
nodeosd logs
```

You can now test your `nodeos` by simply going to `http://SERVER_IP:8888/v1/chain/get_info` if you get a successfull json response it means `nodeos` is working perfectly.

[Home](/tutorials/)