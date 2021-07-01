#!/bin/bash

vpn_connect() {
    sudo openvpn --config #<your_ovpn_config_file>
}

redirect_only() {
    while true :; 
        do cat ./user-agents.txt | while read agents;
            do cat ./urls.txt | while read urls;
                do cat ./webproxy.txt | while read proxy;
                    do curl -I -X GET -s $proxy -A $agents -L $urls; done; 
                done;
            done; 
        done;
}

proxified_connection () {
    curl -s 'http://pubproxy.com/api/proxy?port=80&limit=100' | jq '.data[].ipPort' | tr -d '"' > proxies.txt
    #http_proxy=$(curl -s 'http://pubproxy.com/api/proxy?speed=25&port=80' | jq '.data[].ipPort' | tr -d '"')
    http_proxy=$(curl -s 'http://pubproxy.com/api/proxy?port=80' | jq '.data[].ipPort' | tr -d '"')

    while true :; do
        agents=$(shuf -n 1 ./user-agents.txt)
        proxies=$(shuf -n 1 ./webproxies.txt)
        urls=$(shuf -n 1 ./urls.txt)
        #curl -I -X GET -A "$agents" -x "$proxies" -L "$urls";
        curl -I -X POST -A "$agents" -x "$proxies" -L "$urls";
    done;
}


webproxy_connection () {
    while true :; do
        agents=$(shuf -n 1 ./user-agents.txt)
        urls=$(shuf -n 1 ./urls.txt)
        webproxy=$(shuf -n 1 ./webproxy.txt)
        #curl -s -I -X GET -A "$agents" "$webproxy" -L "$urls";
        time=$(date +%T)
        status=$(curl -s -I -X POST -A "$agents" "$webproxy" -L "$urls" 2>/dev/null | head -n1 | awk {'print $2'}; sleep 1;)
        
        if (( $status == 302 )); then
            echo -e "[\033[35m$time\033[0m](\033[32m!GOOD\033[0m) traffic generated now redirecting : \033[36m$urls\033[0m";
        else 
            echo -e "[\033[35m$time\033[0m](\033[31m!ERROR\033[0m) check internet connection, webproxy and urls, bugged!";
        fi
    
    done;
}


#vpn_connect
#proxified_connection
webproxy_connection
cat /dev/null > proxies.txt
