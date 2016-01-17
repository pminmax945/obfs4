Original README (from tor) moved to README.md.orig

This is a fork easier used as obfuscating TCP proxy .

Long story short, you can use ptproxy (https://github.com/gumblex/ptproxy 
needs python3) + unmodified obfs4proxy to achieve this goal. 

But this fork still provides some advantages :

 --No python needed, suitable for very low end device 
  (etc. run on OpenWRT/DD-WRT router, save memory/space ,or no pre-built python3)
 --Support multi ports forward (remote can be on different servers) in one 
   process, easier maintains.
   

How to use this obfs4proxy (to obfuscate shadowsocks for example):

server (public ip 234.12.56.2) : runs shadowsocks-server and obfs4proxy (server mode)
client (your router )          : runs shadowsocks-client and obfs4proxy (client mode)

(note: obfs4poxy is same executable for client/server mode)



server side: 

shadowsocks-server needs no config change (suppose it listen on 234.12.56.2:33)
put runserver.sh and obfs4proxy together, runserver.sh looks like following:



#!/bin/sh
export TOR_PT_STATE_LOCATION=$PWD
export TOR_PT_MANAGED_TRANSPORT_VER="1"
export TOR_PT_SERVER_TRANSPORTS="obfs4"
#                 this is ip:port your obfs4 client<=>server communicate
export TOR_PT_SERVER_BINDADDR="obfs4-234.12.56.2:9999"

#                 this is ip:port your shadowsocks server listen on 
export TOR_PT_ORPORT="234.12.56.2:33"
./obfs4proxy

run runserver.sh ,it will print something likes 

SMETHOD obfs4 234.12.56.2:9999 ARGS:cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw;iat-mode=0

remember ARGS part:  ----> cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw,iat-mode=0 <--------
DO NOT COPY ARGS FROM THIS PAGE, COPY ARGS FROM YOUR SERVER ,THAT IS DIFFERENT 
FROM DIFFERENT SERVER




client side:

put runclient.sh ,obfs4proxy, client.json together

client.json looks like

{"obfs4":[

    {"ListenAddr":"127.0.0.1:7777",        -------> this is ip:port your shadowsocks-client should connect to
     "ServerAddr":"234.12.56.2:9999",      -------> this is TOR_PT_SERVER_BIND_ADDR variable in your runserver.sh
     "PtArgs":"cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw,iat-mode=0"   ---> you just remembered
    }
]}

shadowsocks-client config should change from original 

"server" : "234.12.56.2"
"server_port": 33

to new ones :

"server" : "127.0.0.1"      ----------->ListenAddr ip part of your client.json
"server_port" : "7777"      ----------->ListenAddr port part of your client.json


run runclient.sh
run your shadowsocks-client

now your shadowsocks client<=>server communicate will be obfused by obfs4proxy

you can custom runclient.sh TCP_PROXY_CONFIG_FILE variable to use config file 
other than 'client.json'

you can quick test this obfused channel by run nc
(shutdown shadowsocks of both sides first):

server : nc -l -p 33
client : nc 127.0.0.1 7777

type some lines ,you should see lines from each other.
if this not work, you should check if ARGS is incorrect

you can also changes runserver.sh runclient.sh 
./obfs4proxy command to
./obfs4proxy -logLevel=INFO -enableLogging=true

then check obfs4proxy.log for detail information


multiports client.json example:

{"obfs4":[

    {"ListenAddr":"127.0.0.1:7777", 
     "ServerAddr":"234.12.56.2:9999", 
     "PtArgs":"ptargs printed by this server" 
    },
    {"ListenAddr":"127.0.0.1:7778",  
     "ServerAddr":"23.125.56.23:2349", 
     "PtArgs":"ptargs printed by that server" 
    }
],
"obfs3":[
    {"ListenAddr":"127.0.0.1:342", 
     "ServerAddr":"34.31.25.72:699", 
     "PtArgs":"" 
    }
]
}





Background:

ptproxy + obfs4proxy TCP proxy works as following:

                                                          |
                                               Client Part|Server Part
                                                          |
                   +-----------+      +-------------------+--------------------+
        tcp forward| (python3) |socks5|                obfused tcp             | tcp forward 
 your client <=====|=>ptproxy<=|======|=> obfs client <===|====> obfs server <=|=> your server
                   +-----------+      | (as socks5 proxy) |    (as tcp forward)|   
                 exchange tcp and     +-------------------+--------------------+
                 socks5 streams                           | 
                                                          
To use original obfs as TCP proxy you must pass obfs parameters as socks5 
username/password (obfs transport designed as this since it can multiplex 
multi server channel as one socks5 listen port)

ptproxy  did this job, but it's writtern in python, which may not suitable for
low end router (nor cheep vps). so I did a little hack on obfs, export TCP 
channel directly (instead of socks5), omit socks5 TCP convert stage

my obfs fork works as following


                         Client Part|Server Part
                                     |
                 +-------------------+--------------------+
                 |                obfused tcp             | tcp forward 
 your client <===|=> my obfs fork<===|====> obfs server <=|=> your server
                 | (as tcp forward)  |    (as tcp forward)|   
                 +-------------------+--------------------+
                 [changed code][unchanged,same as original]

notes: only change listen part, no change to obfs protocol or any server side,
server-client communicate code, so you can use original obfs4proxy binary with 
my runserver.sh on server side. also can use original obfs4proxy binary with 
ptproxy on server side




---------------------------------------------------------中文---------------

原说明重命名为 README.md.orig


本fork用于方便的用作TCP混淆代理

简单地说，你可以使用 ptproxy (https://github.com/gumblex/ptproxy 
需要python3) + 原版obfs4proxy 来达到同样的效果

但是本分支提供以下优势：

 --不需要python, 适合低端设备(比如在路由器上运行，无需python的内存和flash占用.
   或者一些路由系统并没有预编译的python,交叉编译很麻烦）
 --单进程支持多个端口代理(远程端口也可在不同服务器上)，降低维护难度和重复进程的
   资源占用
   

如何使用本obfs4proxy (以混淆shadowsocks流量为例):

服务器(假设公网 ip 234.12.56.2) : 运行 shadowsocks-server 和 obfs4proxy (服务端模式)
客户端 (比如你的路由器 )    : 运行 shadowsocks-client 和 obfs4proxy (客户端模式)


(obfs4proxy客户端和服务端是同一个可执行文件)

服务端: 

shadowsocks-server 无需配置修改(假设原来的监听地址为 234.12.56.2:33)
将runserver.sh obfs4proxy 放置于服务器端同一目录, runserver.sh 内容如下:



#!/bin/sh
export TOR_PT_STATE_LOCATION=$PWD
export TOR_PT_MANAGED_TRANSPORT_VER="1"
export TOR_PT_SERVER_TRANSPORTS="obfs4"
#                 此为obfs4 客户端<=>服务端 通信的地址
export TOR_PT_SERVER_BINDADDR="obfs4-234.12.56.2:9999"

#                 此为shadowsocks server 监听的地址 
export TOR_PT_ORPORT="234.12.56.2:33"
./obfs4proxy

运行 runserver.sh ,将输出如下： 

SMETHOD obfs4 234.12.56.2:9999 ARGS:cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw;iat-mode=0

记住ARGS部分:  ----> cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw,iat-mode=0 <--------
不要拷贝此页面里的ARGS,而是拷贝你自己服务器上输出的那一个。




客户端:
将runclient.sh ,obfs4proxy, client.json 放置于客户端同一目录下，

client.json 如下

{"obfs4":[

    {"ListenAddr":"127.0.0.1:7777",        -------> 此地址为 shadowsocks-client 配置文件中服务端的地址和端口
     "ServerAddr":"234.12.56.2:9999",      -------> 此地址为服务器端脚本中 TOR_PT_SERVER_BIND_ADDR 变量的值
     "PtArgs":"cert=tMAfVnvB4Y0PpZanelDI338h5FDz60wgo98Kari9yeBxe/3g2qtCWY2grRgLHbwToY0IFw,iat-mode=0"  记下的服务器端输出的内容 
    }
]}

shadowsocks-client 配置由原来的 

"server" : "234.12.56.2"
"server_port": 33

修改为:

"server" : "127.0.0.1"      ----------->client.json 中ListenAddr的地址
"server_port" : "7777"      ----------->client.json 中ListenAddr的端口


运行 runclient.sh
运行 shadowsocks-client

现在 shadowsocks 的流量均由obfs4proxy混淆


注释：如想使用client.json之外的配置文件名，可修改runclient.sh中
TCP_PROXY_CONFIG_FILE变量的内容

可使用nc检测下混淆通道是否工作正常(先停止两侧的shadowsocks进程)：

服务器: nc -l -p 33
客户端: nc 127.0.0.1 7777

随便输入几行内容，应该互相可见，若有问题，估计是ARGS写错了

也可修改runserver.sh runclient.sh 中
./obfs4proxy 为
./obfs4proxy -logLevel=INFO -enableLogging=true

然后查看obfs4proxy.log的详细信息


多端口代理的client.json配置:

{"obfs4":[

    {"ListenAddr":"127.0.0.1:7777", 
     "ServerAddr":"234.12.56.2:9999", 
     "PtArgs":"这个服务器输出的ptargs" 
    },
    {"ListenAddr":"127.0.0.1:7778",  
     "ServerAddr":"23.125.56.23:2349", 
     "PtArgs":"那个服务器输出的ptargs" 
    }
],
"obfs3":[
    {"ListenAddr":"127.0.0.1:342", 
     "ServerAddr":"34.31.25.72:699", 
     "PtArgs":"" 
    }
]
}




原理说明:

ptproxy + obfs4proxy 的工作原理如下：

                                                          |
                                               客户机部分 | 服务器部分
                                                          |
                   +-----------+      +-------------------+--------------------+
        tcp forward| (python3) |socks5|                obfused tcp             | tcp forward 
 你的客户端应用<===|=>ptproxy<=|======|=> obfs client <===|====> obfs server <=|=> 你的服务器端应用
                   +-----------+      | (as socks5 proxy) |    (as tcp forward)|   
                 exchange tcp and     +-------------------+--------------------+
                 socks5 streams                           | 
                                                          
如希望使用原版obfs4proxy作为TCP转发代理你必须将obfs的参数作为socks5代理的用户名
密码传递（obfs设计如此，这样可以复用一个socks5端口来连接多个服务器的通道）

ptproxy  即完成此步骤,但python 可能不适合运行在路由器（或者超便宜的vps）上，
故我对原版obfs 做了一点修改，对外直接开放TCP端口监听，省却了socks5与TCP互转的
流程.

本obfs4proxy 工作原理如下：


                         客户机部分  |服务器部分
                                     |
                 +-------------------+--------------------+
                 |                obfused tcp             | tcp forward 
 your client <===|=> my obfs fork<===|====> obfs server <=|=> your server
                 | (as tcp forward)  |    (as tcp forward)|   
                 +-------------------+--------------------+
                 [修改代码部分][未修改,与原版一致         ]
                                     | 


说明：仅修改了客户端模式下的监听模式代码，原obfs协议以及obfs客户端服务端交互
的代码均无需修改，故服务器上可使用原版obfs4proxy的程序和runserver.sh,也可以使用
原版obfs4proxy+ptproxy
