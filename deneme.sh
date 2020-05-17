#!/bin/bash
apt-get install subversion g++ zlib1g-dev build-essential git python python3 python3-distutils libncurses5-dev gawk gettext unzip file libssl-dev wget libelf-dev ecj fastjar java-propose-classpath
apt-get install build-essential libncursesw5-dev python unzip 
umask 0022
git clone https://git.openwrt.org/openwrt/openwrt.git
