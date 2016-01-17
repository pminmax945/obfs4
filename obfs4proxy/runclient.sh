#!/bin/sh
export TOR_PT_STATE_LOCATION=$PWD
export TOR_PT_MANAGED_TRANSPORT_VER="1"
export TOR_PT_CLIENT_TRANSPORTS="obfs4,obfs3,obfs2"

# if you want to use config file with other filename, change this
export TCP_PROXY_CONFIG_FILE="client.json"

#if you want detail log in obfs4proxy.log ,use following command
#./obfs4proxy -logLevel=INFO -enableLogging=true
./obfs4proxy

