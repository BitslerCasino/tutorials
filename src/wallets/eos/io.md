---
layout: default
---


## Basic Installation and Usage of EOSIO on Ubuntu 16.04
![eosio-image](https://cdn-images-1.medium.com/max/800/1*t-JGDBRk9__B2-odKWUl2A.jpeg)
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

### Create a Sudo User
Follow this [tutorial](/tutorials/general/createsudouser.md) on how to Create a Sudo User

### Git Installation
```bash
 sudo apt install git
 ```

### Cmake Installation/upgrade
Skip this step if your cmake version is above or equal to 3.4.3 by checking `cmake --version`
Remove old cmake version to avoid errors.
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
```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt  install -y nodejs
sudo apt-get install -y build-essential
```

### EOS Installation
The installation steps below assumes that you have met the requirements above.
Getting the code source of EOS via git clone.
```bash
git  clone https://github.com/EOSIO/eos --recursive
```
Building using Autobuild script.
```bash
cd eos && ./eosio_build.sh
```
This will check your system for required dependencies, and will ask you to install them, so install them as required by choosing number `1` if asked. This process will take awhile, so again have patience.
Once build is finished run:
```bash
./eosio_install.sh
```
