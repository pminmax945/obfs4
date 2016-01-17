#!/bin/sh
export TOR_PT_STATE_LOCATION=$PWD
export TOR_PT_MANAGED_TRANSPORT_VER="1"
export TOR_PT_SERVER_TRANSPORTS="obfs4"

#                 this is ip:port opened on server which 
#                 your obfs4 client<=>server communicate
export TOR_PT_SERVER_BINDADDR="obfs4-127.0.0.1:8838"

#                 this is ip:port your server app listen on 
export TOR_PT_ORPORT="127.0.0.1:1080"

#if you want detail log in obfs4proxy.log ,use following command
#./obfs4proxy -logLevel=INFO -enableLogging=true
./obfs4proxy
