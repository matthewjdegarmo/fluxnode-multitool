#!/bin/bash
# Bootstrap settings
#BOOTSTRAP_ZIP='https://runonflux.zelcore.workers.dev/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz'
BOOTSTRAP_ZIPFILE='flux_explorer_bootstrap.tar.gz'
BOOTSTRAP_URL_MONGOD='https://fluxnodeservice.com/mongod_bootstrap.tar.gz'
BOOTSTRAP_ZIPFILE_MONGOD='mongod_bootstrap.tar.gz'

#wallet information
COIN_NAME='flux'
CONFIG_DIR='.flux'
CONFIG_FILE='flux.conf'
kadena_possible="0"

BENCH_NAME='fluxbench'
BENCH_CLI='fluxbench-cli'
BENCH_DIR_LOG='.fluxbenchmark'

COIN_DAEMON='fluxd'
COIN_CLI='flux-cli'
COIN_PATH='/usr/local/bin'

USERNAME="$(whoami)"
FLUX_DIR='zelflux'

#Install variable
IMPORT_ZELCONF="0"
IMPORT_ZELID="0"
CORRUPTED="0"
BOOTSTRAP_SKIP="0"
WATCHDOG_INSTALL="0"
SKIP_OLD_CHAIN="0"
Server_offline=0

#Zelflux ports
ZELFRONTPORT=16126
LOCPORT=16127
ZELNODEPORT=16128
#MDBPORT=27017
RPCPORT=16124
PORT=16125

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WORNING="${RED}\xF0\x9F\x9A\xA8${NC}"

#dialog color
export NEWT_COLORS='
title=black,
'
function string_limit_check_mark() {
if [[ -z "$2" ]]; then
string="$1"
string=${string::40}
else
string=$1
string_color=$2
string_leght=${#string}
string_leght_color=${#string_color}
string_diff=$((string_leght_color-string_leght))
string=${string_color::40+string_diff}
fi
echo -e "${ARROW} ${CYAN}$string[${CHECK_MARK}${CYAN}]${NC}"
}


function bootstrap_server(){
rand_by_domain=("1" "3" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14")
richable=()
richable_eu=()
richable_us=()
richable_as=()

i=0
len=${#rand_by_domain[@]}
echo -e "${ARROW} ${CYAN}Checking servers availability... ${NC}"
while [ $i -lt $len ];
do
    bootstrap_check=$(curl -sSL -m 10 http://cdn-${rand_by_domain[$i]}.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.json 2>/dev/null | jq -r '.block_height' 2>/dev/null)
    if [[ "$bootstrap_check" != "" ]]; then

       if [[ "${rand_by_domain[$i]}" -le "3" || "${rand_by_domain[$i]}" -gt "11" ]]; then
         richable_eu+=( ${rand_by_domain[$i]}  )
       fi

       if [[ "${rand_by_domain[$i]}" -gt "3" &&  "${rand_by_domain[$i]}" -le "10" ]]; then
         richable_us+=( ${rand_by_domain[$i]}  )
       fi

       if [[ "${rand_by_domain[$i]}" -gt "10" ]]; then
         richable_as+=( ${rand_by_domain[$i]}  )
       fi

        richable+=( ${rand_by_domain[$i]} )
    fi

    i=$(($i+1))
done

server_found="1"
if [[ "$continent" == "EU" ]]; then
  len_eu=${#richable_eu[@]}
  if [[ "$len_eu" -gt "0" ]]; then
    richable=( ${richable_eu[*]} )
    echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
  fi
  if [[ "$len_eu" == "0" ]]; then
     continent="EU"
     echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
     len_us=${#richable_us[@]}
     if [[ "$len_us" -gt "0" ]]; then
      richable=( ${richable_us[*]} )
      echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
     fi
     if [[ "$len_us" == "0" ]]; then
       continent="US"
       echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
       server_found="0"
     fi
   fi
elif [[ "$continent" == "US" ]]; then
  len_us=${#richable_us[@]}
  if [[ "$len_us" -gt "0" ]]; then
    richable=( ${richable_us[*]} )
    echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
  fi
  if [[ "$len_us" == "0" ]]; then
    continent="US"
    echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
    len_as=${#richable_as[@]}
    if [[ "$len_as" -gt "0" ]]; then
     richable=( ${richable_as[*]} )
     echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
    fi
    if [[ "$len_as" == "0" ]]; then
      continent="AS"
      echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
      len_eu=${#richable_eu[@]}
        if [[ "$len_eu" -gt "0" ]]; then
          richable=( ${richable_eu[*]} )
          echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
        fi
       if [[ "$len_eu" == "0" ]]; then
        continent="EU"
        echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
        server_found="0"
       fi
    fi
  fi
elif [[ "$continent" == "AS" ]]; then
  len_as=${#richable_as[@]}
  if [[ "$len_as" -gt "0" ]]; then
    richable=( ${richable_as[*]} )
    echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
  fi
  if [[ "$len_as" == "0" ]]; then
    continent="AS"
    echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
    len_us=${#richable_us[@]}
    if [[ "$len_us" -gt "0" ]]; then
      richable=( ${richable_us[*]} )
      echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
    fi
    if [[ "$len_us" == "0" ]]; then
      continent="US"
      echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
      len_eu=${#richable_eu[@]}
       if [[ "$len_eu" -gt "0" ]]; then
         richable=( ${richable_eu[*]} )
         echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
       fi
       if [[ "$len_eu" == "0" ]]; then
        continent="EU"
        echo -e "${WORNING} ${CYAN}All Bootstrap in $continent are offline, checking other location...${NC}" && sleep 1
        server_found="0"
       fi
    fi
  fi
else
   len=${#richable[@]}
   if [[ "$len" -gt "0" ]]; then
         richable=( ${richable[*]} )
         echo -e "${ARROW} ${CYAN}Reachable servers: ${richable[*]}${NC}"
   fi
   
   if [[ "$len" == "0" ]]; then
    Server_offline=1
    return 1
   fi
fi

if [[ "$server_found" == "0" ]]; then
  len=${#richable[@]}
  if [[ "$len" == "0" ]]; then
    Server_offline=1
    return 1
  fi
fi

Server_offline=0

}

function bootstrap_geolocation(){

IP=$WANIP
ip_output=$(curl -s -m 10 http://ip-api.com/json/$1?fields=status,country,timezone | jq .)
ip_status=$( jq -r .status <<< "$ip_output")

if [[ "$ip_status" == "success" ]]; then
country=$(jq -r .country <<< "$ip_output")
org=$(jq -r .org <<< "$ip_output")
continent=$(jq -r .timezone <<< "$ip_output")
else
country="UKNOW"
continent="UKNOW"
fi

continent=$(cut -f1 -d"/" <<< "$continent" )

if [[ "$continent" =~ "Europe" ]]; then
 continent="EU"
elif [[ "$continent" =~ "America" ]]; then
 continent="US"
elif [[ "$continent" =~ "Asia" ]]; then
 continent="AS"
else
 continent="ALL"
fi

echo -e ""
echo -e "${ARROW} ${YELLOW}Selecting bootstrap server....${NC}"
echo -e "${ARROW} ${CYAN}Node Location: $country, Continent: $continent ${NC}"
echo -e "${ARROW} ${CYAN}Searching in $continent....${NC}"
}


function config_veryfity(){

 if [[ -f /home/$USER/.flux/flux.conf ]]; then
 
    echo -e "${ARROW} ${YELLOW}Checking config file...${NC}"
    insightexplorer=$(cat /home/$USER/.flux/flux.conf | grep 'insightexplorer=1' | wc -l)

    if [[ "$insightexplorer" == "1" ]]; then
  
      echo -e "${ARROW} ${CYAN}Insightexplorer enabled.............[${CHECK_MARK}${CYAN}]${NC}"

    else
    
      echo -e "${ARROW} ${CYAN}Insightexplorer enabled.............[${X_MARK}${CYAN}]${NC}"
      echo -e "${ARROW} ${CYAN}Removing wallet.dat...${NC}"
      echo -e "${ARROW} ${CYAN}Use old chain will be skipped...${NC}"
      sudo rm -rf /home/$USER/$CONFIG_DIR/wallet.dat && sleep 1
      SKIP_OLD_CHAIN="1"

    fi
  
  fi

}


 function selfhosting() {
 
 echo -e "${ARROW} ${YELLOW}Creating cron service for ip rotate...${NC}"
 echo -e "${ARROW} ${CYAN}Adding IP for device...${NC}" && sleep 1
 device_name=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | head -n1 | awk '{print $2}' | sed 's/://' | sed 's/@/ /' | awk '{print $1}')
 
  if [[ "$device_name" != "" && "$WANIP" != "" ]]; then
    sudo ip addr add $WANIP dev $device_name:0  > /dev/null 2>&1
  else
    echo -e "${WORNING} ${CYAN}Problem detected operation aborted! ${NC}" && sleep 1
    echo -e ""
    return 1
  fi
 
echo -e "${ARROW} ${CYAN}Creating ip check script...${NC}" && sleep 1
sudo rm /home/$USER/ip_check.sh > /dev/null 2>&1
sudo touch /home/$USER/ip_check.sh
sudo chown $USER:$USER /home/$USER/ip_check.sh
    cat <<'EOF' > /home/$USER/ip_check.sh
#!/bin/bash
function get_ip(){
 WANIP=$(curl --silent -m 10 https://api4.my-ip.io/ip | tr -dc '[:alnum:].')
    
  if [[ "$WANIP" == "" || "$WANIP" = *html* ]]; then
   WANIP=$(curl --silent -m 10 https://checkip.amazonaws.com | tr -dc '[:alnum:].')    
  fi  
      
  if [[ "$WANIP" == "" || "$WANIP" = *html* ]]; then
   WANIP=$(curl --silent -m 10 https://api.ipify.org | tr -dc '[:alnum:].')
  fi
}
if [[ $1 == "restart" ]]; then
  # give 3min to connect with internet
  sleep 180
  get_ip
  device_name=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | head -n1 | awk '{print $2}' | sed 's/://' | sed 's/@/ /' | awk '{print $1}')
  if [[ "$device_name" != "" && "$WANIP" != "" ]]; then
   date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
   echo -e "New IP detected, IP: $WANIP was added at $date_timestamp" >> /home/$USER/ip_history.log
   sudo ip addr add $WANIP dev $device_name:0 && sleep 2
  fi
fi
if [[ $1 == "ip_check" ]]; then
  get_ip
  device_name=$(ip addr | grep 'BROADCAST,MULTICAST,UP,LOWER_UP' | head -n1 | awk '{print $2}' | sed 's/://' | sed 's/@/ /' | awk '{print $1}')
  api_port=$(grep -w apiport /home/$USER/zelflux/config/userconfig.js | grep -o '[[:digit:]]*')
  if [[ "$api_port" == "" ]]; then
  api_port="16127"
  fi
  confirmed_ip=$(curl -SsL -m 10 http://localhost:$api_port/flux/info | jq -r .data.node.status.ip | sed -r 's/:.+//')
  if [[ "$WANIP" != "" && "$confirmed_ip" != "" ]]; then
    if [[ "$WANIP" != "$confirmed_ip" ]]; then
      date_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
      echo -e "New IP detected, IP: $WANIP was added at $date_timestamp" >> /home/$USER/ip_history.log
      sudo ip addr add $WANIP dev $device_name:0 && sleep 2
    fi
  fi
fi
EOF

sudo chmod +x /home/$USER/ip_check.sh
echo -e "${ARROW} ${CYAN}Adding cron jobs...${NC}" && sleep 1

#crontab_check=$(sudo cat /var/spool/cron/crontabs/$USER | grep -o ip_check | wc -l)
sudo [ -f /var/spool/cron/crontabs/$USER ] && crontab_check=$(sudo cat /var/spool/cron/crontabs/$USER | grep -o ip_check | wc -l) || crontab_check=0

if [[ "$crontab_check" == "0" ]]; then
  (crontab -l -u "$USER" 2>/dev/null; echo "@reboot /home/$USER/ip_check.sh restart") | crontab -
  (crontab -l -u "$USER" 2>/dev/null; echo "*/15 * * * * /home/$USER/ip_check.sh ip_check") | crontab -
  echo -e "${ARROW} ${CYAN}Script installed! ${NC}" 
else
  echo -e "${ARROW} ${CYAN}Cron jobs already added! ${NC}" 
  echo -e "${ARROW} ${CYAN}Script installed! ${NC}"
fi
echo -e "" 
 }


function max(){

    m="0"
    for n in "$@"
    do        
        if egrep -o "^[0-9]+$" <<< "$n" &>/dev/null; then
            [ "$n" -gt "$m" ] && m="$n"
        fi
    done
    
    echo "$m"
    
}

function string_limit_x_mark() {
if [[ -z "$2" ]]; then
string="$1"
string=${string::40}
else
string=$1
string_color=$2
string_leght=${#string}
string_leght_color=${#string_color}
string_diff=$((string_leght_color-string_leght))
string=${string_color::40+string_diff}
fi
echo -e "${ARROW} ${CYAN}$string[${X_MARK}${CYAN}]${NC}"
}


function integration_check() {
FILE_ARRAY=( 'fluxbench-cli' 'fluxbenchd' 'flux-cli' 'fluxd' 'flux-fetch-params.sh' 'flux-tx' )
ELEMENTS=${#FILE_ARRAY[@]}

for (( i=0;i<$ELEMENTS;i++)); do

string="${FILE_ARRAY[${i}]}................................."
string=${string::40}

if [ -f "$COIN_PATH/${FILE_ARRAY[${i}]}" ]; then
  echo -e "${ARROW}${CYAN} $string[${CHECK_MARK}${CYAN}]${NC}"
else
  echo -e "${ARROW}${CYAN} $string[${X_MARK}${CYAN}]${NC}"
  CORRUPTED="1"
fi

done

if [[ "$CORRUPTED" == "1" ]]; then
  echo -e "${WORNING} ${CYAN}Flux daemon package corrupted...${NC}"
  echo -e "${WORNING} ${CYAN}Will exit out so try and run the script again...${NC}"
  echo
  exit
fi	
echo -e ""
}

function tier(){

if [[ -f /home/$USER/$CONFIG_DIR/$CONFIG_FILE ]]; then
  index_from_file=$(grep -w zelnodeindex /home/$USER/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeindex=//')
  tx_from_file=$(grep -w zelnodeoutpoint /home/$USER/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeoutpoint=//')
  stak_info=$(curl -s -m 5 https://explorer.runonflux.io/api/tx/$tx_from_file | jq -r ".vout[$index_from_file] | .value,.n,.scriptPubKey.addresses[0],.spentTxId" | paste - - - - | awk '{printf "%0.f %d %s %s\n",$1,$2,$3,$4}' | grep 'null' | egrep -o '10000|25000|100000|1000|12500|40000')
	
    if [[ "$stak_info" == "" ]]; then
      stak_info=$(curl -s -m 5 https://explorer.zelcash.online/api/tx/$tx_from_file | jq -r ".vout[$index_from_file] | .value,.n,.scriptPubKey.addresses[0],.spentTxId" | paste - - - - | awk '{printf "%0.f %d %s %s\n",$1,$2,$3,$4}' | grep 'null' | egrep -o '10000|25000|100000|1000|12500|40000')
    fi	


  if [[ $stak_info == ?(-)+([0-9]) ]]; then

   case $stak_info in
    "25000")  kadena_possible=1 ;;
    "100000") kadena_possible=1 ;;
    "12500")  kadena_possible=1 ;;
    "40000") kadena_possible=1 ;;
   esac
 
  else
    kadena_possible=0
  fi

fi

}

function config_file() {

if [[ -f /home/$USER/install_conf.json ]]; then
import_settings=$(cat /home/$USER/install_conf.json | jq -r '.import_settings')
#ssh_port=$(cat /home/$USER/install_conf.json | jq -r '.ssh_port')
#firewall_disable=$(cat /home/$USER/install_conf.json | jq -r '.firewall_disable')
bootstrap_url=$(cat /home/$USER/install_conf.json | jq -r '.bootstrap_url')
bootstrap_zip_del=$(cat /home/$USER/install_conf.json | jq -r '.bootstrap_zip_del')
#swapon=$(cat /home/$USER/install_conf.json | jq -r '.swapon')
#mongo_bootstrap=$(cat /home/$USER/install_conf.json | jq -r '.mongo_bootstrap')
#watchdog=$(cat /home/$USER/install_conf.json | jq -r '.watchdog')
use_old_chain=$(cat /home/$USER/install_conf.json | jq -r '.use_old_chain')
prvkey=$(cat /home/$USER/install_conf.json | jq -r '.prvkey')
outpoint=$(cat /home/$USER/install_conf.json | jq -r '.outpoint')
index=$(cat /home/$USER/install_conf.json | jq -r '.index')
ZELID=$(cat /home/$USER/install_conf.json | jq -r '.zelid')
KDA_A=$(cat /home/$USER/install_conf.json | jq -r '.kda_address')
fix_action=$(cat /home/$USER/install_conf.json | jq -r '.action')
node_label=$(cat /home/$USER/install_conf.json | jq -r '.node_label')
eps_limit=$(cat /home/$USER/install_conf.json | jq -r '.eps_limit')
discord=$(cat /home/$USER/install_conf.json | jq -r '.discord')
ping=$(cat /home/$USER/install_conf.json | jq -r '.ping')
telegram_alert=$(cat /home/$USER/install_conf.json | jq -r '.telegram_alert')
telegram_bot_token=$(cat /home/$USER/install_conf.json | jq -r '.telegram_bot_token')
telegram_chat_id=$(cat /home/$USER/install_conf.json | jq -r '.telegram_chat_id')

   
	  

echo
echo -e "${ARROW} ${YELLOW}Install config:"

if [[ "$prvkey" != "" && "$outpoint" != "" && "$index" != "" ]];then
echo -e "${PIN}${CYAN} Import settings from install_conf.json...........................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
else

if [[ "$import_settings" == "1" ]]; then
echo -e "${PIN}${CYAN} Import settings from Flux........................................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
fi

fi


if [[ "$use_old_chain" == "1" ]]; then
echo -e "${PIN}${CYAN} Diuring re-installation old chain will be use....................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1

else

if [[ "$bootstrap_url" == "0" ]]; then
echo -e "${PIN}${CYAN} Use Flux daemon bootstrap from source build in scripts...........[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
else
echo -e "${PIN}${CYAN} Use Flux daemon bootstrap from own source........................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
fi

if [[ "$bootstrap_zip_del" == "1" ]]; then
echo -e "${PIN}${CYAN} Remove Flux daemon bootstrap archive file........................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
else
echo -e "${PIN}${CYAN} Leave Flux daemon bootstrap archive file.........................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
fi

fi

#if [[ "$swapon" == "1" ]]; then
#echo -e "${PIN}${CYAN} Create a file that will be used for swap.........................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
#fi

#if [[ "$mongo_bootstrap" == "1" ]]; then
#echo -e "${PIN}${CYAN} Use Bootstrap for MongoDB........................................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
#fi

if [[ "$discord" != "" || "$telegram_alert" == '1' ]]; then
echo -e "${PIN}${CYAN} Enable watchdog notification.....................................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
else
echo -e "${PIN}${CYAN} Disable watchdog notification....................................[${CHECK_MARK}${CYAN}]${NC}" && sleep 1
fi



fi
}

function round() {
  printf "%.${2}f" "${1}"
}

function check_benchmarks() {

 var_benchmark=$($BENCH_CLI getbenchmarks | jq ".$1")
 limit=$2
 if [[ $(echo "$limit>$var_benchmark" | bc) == "1" ]]
 then
  var_round=$(round "$var_benchmark" 2)
  echo -e "${X_MARK} ${CYAN}$3 $var_round $4${NC}"
 fi

}

function import_date() {

if [[ -f /home/$USER/$CONFIG_DIR/$CONFIG_FILE || -f /home/$USER/.zelcash/zelcash.conf ]]; then

    if [[ -z "$import_settings" ]]; then

        if whiptail --yesno "Would you like to import data from Flux config files Y/N?" 8 60; then
	
	    OLD_CONFIG=0
	
	    if [[ -d /home/$USER/.zelcash ]]; then
	     CONFIG_DIR='.zelcash'
	     CONFIG_FILE='zelcash.conf' 
	     OLD_CONFIG=1
	    fi
	    
            IMPORT_ZELCONF="1"
            echo
            echo -e "${ARROW} ${YELLOW}Imported settings:${NC}"
            zelnodeprivkey=$(grep -w zelnodeprivkey ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeprivkey=//')
            echo -e "${PIN}${CYAN} Identity Key = ${GREEN}$zelnodeprivkey${NC}" && sleep 1
            zelnodeoutpoint=$(grep -w zelnodeoutpoint ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeoutpoint=//')
            echo -e "${PIN}${CYAN} Output TX ID = ${GREEN}$zelnodeoutpoint${NC}" && sleep 1
            zelnodeindex=$(grep -w zelnodeindex ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeindex=//')
            echo -e "${PIN}${CYAN} Output Index = ${GREEN}$zelnodeindex${NC}" && sleep 1
	    
	    if [[ "$OLD_CONFIG" == "1" ]]; then 
	       CONFIG_DIR='.flux'
	       CONFIG_FILE='flux.conf' 
	    fi

           if [[ -f ~/$FLUX_DIR/config/userconfig.js ]]; then
               
               ZELID=$(grep -w zelid ~/$FLUX_DIR/config/userconfig.js | sed -e 's/.*zelid: .//' | sed -e 's/.\{2\}$//') 
	       if [[ "$ZELID" != "" ]]; then
	         echo -e "${PIN}${CYAN} Zel ID = ${GREEN}$ZELID${NC}" && sleep 1
	         IMPORT_ZELID="1"
	       fi

              KDA_A=$(grep -w kadena ~/$FLUX_DIR/config/userconfig.js | sed -e 's/.*kadena: .//' | sed -e 's/.\{2\}$//')
              if [[ "$KDA_A" != "" ]]; then
                  echo -e "${PIN}${CYAN} KDA address = ${GREEN}$KDA_A${NC}" && sleep 1
              fi
	      
	      echo -e ""
	      echo -e "${ARROW} ${YELLOW}Imported watchdog settings:${NC}"
	      
              node_label=$(grep -w label /home/$USER/watchdog/config.js | sed -e 's/.*label: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$node_label" != "" && "$node_label" != "0" ]]; then
	      echo -e "${PIN}${CYAN} Label = ${GREEN}Enabled${NC}" && sleep 1
	      else
	      echo -e "${PIN}${CYAN} Label = ${RED}Disabled${NC}" && sleep 1
	      fi
	      eps_limit=$(grep -w tier_eps_min /home/$USER/watchdog/config.js | sed -e 's/.*tier_eps_min: .//' | sed -e 's/.\{2\}$//')
	      echo -e "${PIN}${CYAN} Tier_eps_min = ${GREEN}$eps_limit${NC}" && sleep 1    
	      discord=$(grep -w web_hook_url /home/$USER/watchdog/config.js | sed -e 's/.*web_hook_url: .//' | sed -e 's/.\{2\}$//')	      
	      if [[ "$discord" != "" && "$discord" != "0" ]]; then
	       echo -e "${PIN}${CYAN} Discord alert = ${GREEN}Enabled${NC}" && sleep 1
	      else
	       echo -e "${PIN}${CYAN} Discord alert = ${RED}Disabled${NC}" && sleep 1
	      fi
	      ping=$(grep -w ping /home/$USER/watchdog/config.js | sed -e 's/.*ping: .//' | sed -e 's/.\{2\}$//')    
	      if [[ "$ping" != "" && "$ping" != "0" ]]; then
	      
	        if [[ "$discord" != "" && "$discord" != "0" ]]; then
	         echo -e "${PIN}${CYAN} Discord ping = ${GREEN}Enabled${NC}" && sleep 1
	        else
	         echo -e "${PIN}${CYAN} Discord ping = ${RED}Disabled${NC}" && sleep 1
	        fi
	      
	      fi
	      
	      telegram_alert=$(grep -w telegram_alert /home/$USER/watchdog/config.js | sed -e 's/.*telegram_alert: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$telegram_alert" != "" && "$telegram_alert" != "0" ]]; then
	       echo -e "${PIN}${CYAN} Telegram alert = ${GREEN}Enabled${NC}" && sleep 1
	      else
	       echo -e "${PIN}${CYAN} Telegram alert = ${RED}Disabled${NC}" && sleep 1
	      fi
	      
	      telegram_bot_token=$(grep -w telegram_bot_token /home/$USER/watchdog/config.js | sed -e 's/.*telegram_bot_token: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$telegram_alert" == "1" ]]; then
	        echo -e "${PIN}${CYAN} Telegram bot token = ${GREEN}$telegram_alert${NC}" && sleep 1	
	      fi
	      
	      telegram_chat_id=$(grep -w telegram_chat_id /home/$USER/watchdog/config.js | sed -e 's/.*telegram_chat_id: .//' | sed -e 's/.\{1\}$//')
	      if [[ "$telegram_alert" == "1" ]]; then
	      echo -e "${PIN}${CYAN} Telegram chat id = ${GREEN}$telegram_chat_id${NC}" && sleep 1	
	      fi

         fi
    fi

else 

    if [[ "$import_settings" == "1" ]]; then
    
        OLD_CONFIG=0
	
	if [[ -d /home/$USER/.zelcash ]]; then
	   CONFIG_DIR='.zelcash'
	   CONFIG_FILE='zelcash.conf' 
	   OLD_CONFIG=1
	fi 
    
    IMPORT_ZELCONF="1"
    echo
    echo -e "${ARROW} ${YELLOW}Imported settings:${NC}"
    zelnodeprivkey=$(grep -w zelnodeprivkey ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeprivkey=//')
    echo -e "${PIN}${CYAN} Identity Key = ${GREEN}$zelnodeprivkey${NC}" && sleep 1
    zelnodeoutpoint=$(grep -w zelnodeoutpoint ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeoutpoint=//')
    echo -e "${PIN}${CYAN} Output TX ID = ${GREEN}$zelnodeoutpoint${NC}" && sleep 1
    zelnodeindex=$(grep -w zelnodeindex ~/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeindex=//')
    echo -e "${PIN}${CYAN} Output Index = ${GREEN}$zelnodeindex${NC}" && sleep 1
    
     if [[ "$OLD_CONFIG" == "1" ]]; then 
	  CONFIG_DIR='.flux'
	  CONFIG_FILE='flux.conf' 
     fi
    

         if [[ -f ~/$FLUX_DIR/config/userconfig.js ]]; then
	 
               ZELID=$(grep -w zelid ~/$FLUX_DIR/config/userconfig.js | sed -e 's/.*zelid: .//' | sed -e 's/.\{2\}$//')
	       if [[ "$ZELID" != "" ]]; then
	         echo -e "${PIN}${CYAN} Zel ID = ${GREEN}$ZELID${NC}" && sleep 1
	         IMPORT_ZELID="1"
	       fi
	       
               KDA_A=$(grep -w kadena ~/$FLUX_DIR/config/userconfig.js | sed -e 's/.*kadena: .//' | sed -e 's/.\{2\}$//')
               if [[ "$KDA_A" != "" ]]; then
                    echo -e "${PIN}${CYAN} KDA address = ${GREEN}$KDA_A${NC}" && sleep 1
               fi
	       	       
         fi
	 
	 
	      echo -e ""
	      echo -e "${ARROW} ${YELLOW}Imported watchdog settings:${NC}"
	      
              node_label=$(grep -w label /home/$USER/watchdog/config.js | sed -e 's/.*label: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$node_label" != "" && "$node_label" != "0" ]]; then
	      echo -e "${PIN}${CYAN} Label = ${GREEN}Enabled${NC}" && sleep 1
	      else
	      echo -e "${PIN}${CYAN} Label = ${RED}Disabled${NC}" && sleep 1
	      fi
	      eps_limit=$(grep -w tier_eps_min /home/$USER/watchdog/config.js | sed -e 's/.*tier_eps_min: .//' | sed -e 's/.\{2\}$//')
	      echo -e "${PIN}${CYAN} Tier_eps_min = ${GREEN}$eps_limit${NC}" && sleep 1    
	      discord=$(grep -w web_hook_url /home/$USER/watchdog/config.js | sed -e 's/.*web_hook_url: .//' | sed -e 's/.\{2\}$//')	      
	      if [[ "$discord" != "" && "$discord" != "0" ]]; then
	       echo -e "${PIN}${CYAN} Discord alert = ${GREEN}Enabled${NC}" && sleep 1
	      else
	       echo -e "${PIN}${CYAN} Discord alert = ${RED}Disabled${NC}" && sleep 1
	      fi
	      ping=$(grep -w ping /home/$USER/watchdog/config.js | sed -e 's/.*ping: .//' | sed -e 's/.\{2\}$//')    
	      if [[ "$ping" != "" && "$ping" != "0" ]]; then
	      
	        if [[ "$discord" != "" && "$discord" != "0" ]]; then
	         echo -e "${PIN}${CYAN} Discord ping = ${GREEN}Enabled${NC}" && sleep 1
	        else
	         echo -e "${PIN}${CYAN} Discord ping = ${RED}Disabled${NC}" && sleep 1
	        fi
	      
	      fi
	      
	      telegram_alert=$(grep -w telegram_alert /home/$USER/watchdog/config.js | sed -e 's/.*telegram_alert: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$telegram_alert" != "" && "$telegram_alert" != "0" ]]; then
	       echo -e "${PIN}${CYAN} Telegram alert = ${GREEN}Enabled${NC}" && sleep 1
	      else
	       echo -e "${PIN}${CYAN} Telegram alert = ${RED}Disabled${NC}" && sleep 1
	      fi
	      
	      telegram_bot_token=$(grep -w telegram_bot_token /home/$USER/watchdog/config.js | sed -e 's/.*telegram_bot_token: .//' | sed -e 's/.\{2\}$//')
	      if [[ "$telegram_alert" == "1" ]]; then
	        echo -e "${PIN}${CYAN} Telegram bot token = ${GREEN}$telegram_alert${NC}" && sleep 1	
	      fi
	      
	      telegram_chat_id=$(grep -w telegram_chat_id /home/$USER/watchdog/config.js | sed -e 's/.*telegram_chat_id: .//' | sed -e 's/.\{1\}$//')
	      if [[ "$telegram_alert" == "1" ]]; then
	      echo -e "${PIN}${CYAN} Telegram chat id = ${GREEN}$telegram_chat_id${NC}" && sleep 1	
	      fi	
	   
      fi

   fi
fi
sleep 1
echo
}

function tar_file_unpack()
{
    echo -e "${ARROW} ${YELLOW}Unpacking bootstrap archive file...${NC}"
    pv $1 | tar -zx -C $2
}


function check_tar()
{
    echo -e "${ARROW} ${YELLOW}Checking  bootstrap file integration...${NC}"
    
    if gzip -t "$1" &>/dev/null; then
    
        echo -e "${ARROW} ${CYAN}Bootstrap file is valid.................[${CHECK_MARK}${CYAN}]${NC}"
	
    else
    
        echo -e "${ARROW} ${CYAN}Bootstrap file is corrupted.............[${X_MARK}${CYAN}]${NC}"
	rm -rf $1
	
    fi
}


function install_watchdog() {
echo -e "${ARROW} ${YELLOW}Install watchdog for FluxNode${NC}"
if pm2 -v > /dev/null 2>&1
then
WATCHDOG_INSTALL="1"
echo -e "${ARROW} ${YELLOW}Downloading...${NC}"
cd && git clone https://github.com/RunOnFlux/fluxnode-watchdog.git watchdog > /dev/null 2>&1
echo -e "${ARROW} ${YELLOW}Installing git hooks....${NC}"
wget https://raw.githubusercontent.com/RunOnFlux/fluxnode-multitool/master/post-merge > /dev/null 2>&1
mv post-merge /home/$USER/watchdog/.git/hooks/post-merge
sudo chmod +x /home/$USER/watchdog/.git/hooks/post-merge
echo -e "${ARROW} ${YELLOW}Installing watchdog module....${NC}"
cd watchdog && npm install > /dev/null 2>&1
echo -e "${ARROW} ${CYAN}Creating config file....${NC}"

flux_update='0'
daemon_update='0'
bench_update='0'
fix_action='1'

if [[ "$import_settings" == "0"  && -f /home/$USER/install_conf.json ]]; then

sudo touch /home/$USER/watchdog/config.js
sudo chown $USER:$USER /home/$USER/watchdog/config.js
    cat << EOF >  /home/$USER/watchdog/config.js
module.exports = {
    label: '${node_label}',
    tier_eps_min: '${eps_limit}',
    zelflux_update: '${flux_update}',
    zelcash_update: '${daemon_update}',
    zelbench_update: '${bench_update}',
    action: '${fix_action}',
    ping: '${ping}',
    web_hook_url: '${discord}',
    telegram_alert: '${telegram_alert}',
    telegram_bot_token: '${telegram_bot_token}',
    telegram_chat_id: '${telegram_chat_id}'
}
EOF



  if [[ -f /home/$USER/watchdog/watchdog.js ]]; then
    current_ver=$(jq -r '.version' /home/$USER/watchdog/package.json)
    string_limit_check_mark "Watchdog v$current_ver installed................................." "Watchdog ${GREEN}v$current_ver${CYAN} installed................................."
    #echo -e "${ARROW} ${YELLOW}Starting watchdog...${NC}"
    pm2 start /home/$USER/watchdog/watchdog.js --name watchdog --watch /home/$USER/watchdog --ignore-watch '"./**/*.git" "./**/*node_modules" "./**/*watchdog_error.log" "./**/*config.js"' --watch-delay 20 > /dev/null 2>&1 
    pm2 save > /dev/null 2>&1
  else
    string_limit_x_mark "Watchdog was not installed................................."
  fi
  
  return 1

fi


if [[ "$IMPORT_ZELCONF" == "1" ]]; then

sudo touch /home/$USER/watchdog/config.js
sudo chown $USER:$USER /home/$USER/watchdog/config.js
    cat << EOF >  /home/$USER/watchdog/config.js
module.exports = {
    label: '${node_label}',
    tier_eps_min: '${eps_limit}',
    zelflux_update: '${flux_update}',
    zelcash_update: '${daemon_update}',
    zelbench_update: '${bench_update}',
    action: '${fix_action}',
    ping: '${ping}',
    web_hook_url: '${discord}',
    telegram_alert: '${telegram_alert}',
    telegram_bot_token: '${telegram_bot_token}',
    telegram_chat_id: '${telegram_chat_id}'
}
EOF



  if [[ -f /home/$USER/watchdog/watchdog.js ]]; then
    current_ver=$(jq -r '.version' /home/$USER/watchdog/package.json)
    string_limit_check_mark "Watchdog v$current_ver installed................................." "Watchdog ${GREEN}v$current_ver${CYAN} installed................................."
    echo -e "${ARROW} ${YELLOW}Starting watchdog...${NC}"
    pm2 start /home/$USER/watchdog/watchdog.js --name watchdog --watch /home/$USER/watchdog --ignore-watch '"./**/*.git" "./**/*node_modules" "./**/*watchdog_error.log" "./**/*config.js"' --watch-delay 20 > /dev/null 2>&1 
    pm2 save > /dev/null 2>&1
  else
    string_limit_x_mark "Watchdog was not installed................................."
  fi
  
  return 1

fi




discord='0'
if whiptail --yesno "Would you like enable alert notification?" 8 60; then

sleep 1
whiptail --msgbox "Info: to select/deselect item use 'space' ...to switch to OK/Cancel use 'tab' " 10 60
sleep 1

CHOICES=$(whiptail --title "Choose options: " --separate-output --checklist "Choose options: " 10 45 5 \
  "1" "Discord notification      " ON \
  "2" "Telegram notification     " OFF 3>&1 1>&2 2>&3 )

if [ -z "$CHOICES" ]; then

  echo -e "${ARROW} ${CYAN}No option was selected...Alert notification disabled! ${NC}"
  sleep 1
  discord="0"
  ping="0"
  telegram_alert="0"
  telegram_bot_token="0"
  telegram_chat_id="0"
  node_label="0"

else
  for CHOICE in $CHOICES; do
    case "$CHOICE" in
    "1")

      discord=$(whiptail --inputbox "Enter your discord server webhook url" 8 65 3>&1 1>&2 2>&3)
      sleep 1

      if whiptail --yesno "Would you like enable nick ping on discord?" 8 60; then

       while true
       do
           ping=$(whiptail --inputbox "Enter your discord user id" 8 60 3>&1 1>&2 2>&3)
          if [[ $ping == ?(-)+([0-9]) ]]; then
             string_limit_check_mark "UserID is valid..........................................."
             break
           else
             string_limit_x_mark "UserID is not valid try again............................."
             sleep 1
          fi
        done

        sleep 1

      else
        ping=0;
        sleep 1
     fi

      ;;
    "2")

 telegram_alert="1"

  while true
     do
        telegram_bot_token=$(whiptail --inputbox "Enter telegram bot token from BotFather" 8 65 3>&1 1>&2 2>&3)
        if [[ $(grep ':' <<< "$telegram_bot_token") != "" ]]; then
           string_limit_check_mark "Bot token is valid..........................................."
           break
         else
           string_limit_x_mark "Bot token is not valid try again............................."
           sleep 1
        fi
    done

  sleep 1

    while true
     do
        telegram_chat_id=$(whiptail --inputbox "Enter your chat id from GetIDs Bot" 8 60 3>&1 1>&2 2>&3)
        if [[ $telegram_chat_id == ?(-)+([0-9]) ]]; then
           string_limit_check_mark "Chat ID is valid..........................................."
           break
         else
           string_limit_x_mark "Chat ID is not valid try again............................."
           sleep 1
        fi
    done

  sleep 1

      ;;
    esac
  done
fi

 while true
     do
       node_label=$(whiptail --inputbox "Enter name of your node (alias)" 8 65 3>&1 1>&2 2>&3)
        if [[ "$node_label" != "" && "$node_label" != "0"  ]]; then
           string_limit_check_mark "Node name is valid..........................................."
           break
         else
           string_limit_x_mark "Node name is not valid try again............................."
           sleep 1
        fi
    done

else

    discord="0"
    ping="0"
    telegram_alert="0"
    telegram_bot_token="0"
    telegram_chat_id="0"
    node_label="0"
    sleep 1
fi


if [[ "$discord" == 0 ]]; then
    ping="0";
fi


if [[ "$telegram_alert" == 0 ]]; then
    telegram_bot_token="0";
    telegram_chat_id="0";
fi

if [[ -f /home/$USER/$CONFIG_DIR/$CONFIG_FILE ]]; then

  index_from_file=$(grep -w zelnodeindex /home/$USER/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeindex=//')
  tx_from_file=$(grep -w zelnodeoutpoint /home/$USER/$CONFIG_DIR/$CONFIG_FILE | sed -e 's/zelnodeoutpoint=//')
  stak_info=$(curl -s -m 5 https://explorer.runonflux.io/api/tx/$tx_from_file | jq -r ".vout[$index_from_file] | .value,.n,.scriptPubKey.addresses[0],.spentTxId" | paste - - - - | awk '{printf "%0.f %d %s %s\n",$1,$2,$3,$4}' | grep 'null' | egrep -o '10000|25000|100000|1000|12500|40000')
	
    if [[ "$stak_info" == "" ]]; then
      stak_info=$(curl -s -m 5 https://explorer.zelcash.online/api/tx/$tx_from_file | jq -r ".vout[$index_from_file] | .value,.n,.scriptPubKey.addresses[0],.spentTxId" | paste - - - - | awk '{printf "%0.f %d %s %s\n",$1,$2,$3,$4}' | grep 'null' | egrep -o '10000|25000|100000|1000|12500|40000')
    fi	
    
fi

if [[ $stak_info == ?(-)+([0-9]) ]]; then

  case $stak_info in
   "10000") eps_limit=90 ;;
   "25000")  eps_limit=180 ;;
   "100000") eps_limit=300 ;;
   "1000") eps_limit=90 ;;
   "12500")  eps_limit=180 ;;
   "40000") eps_limit=300 ;;
  esac
 
else
eps_limit=0;
fi


sudo touch /home/$USER/watchdog/config.js
sudo chown $USER:$USER /home/$USER/watchdog/config.js
    cat << EOF >  /home/$USER/watchdog/config.js
module.exports = {
    label: '${node_label}',
    tier_eps_min: '${eps_limit}',
    zelflux_update: '${flux_update}',
    zelcash_update: '${daemon_update}',
    zelbench_update: '${bench_update}',
    action: '${fix_action}',
    ping: '${ping}',
    web_hook_url: '${discord}',
    telegram_alert: '${telegram_alert}',
    telegram_bot_token: '${telegram_bot_token}',
    telegram_chat_id: '${telegram_chat_id}'
}
EOF

#echo -e "${ARROW} ${YELLOW}Starting watchdog...${NC}"
pm2 start /home/$USER/watchdog/watchdog.js --name watchdog --watch /home/$USER/watchdog --ignore-watch '"./**/*.git" "./**/*node_modules" "./**/*watchdog_error.log" "./**/*config.js"' --watch-delay 20 > /dev/null 2>&1 
pm2 save > /dev/null 2>&1
if [[ -f /home/$USER/watchdog/watchdog.js ]]
then
current_ver=$(jq -r '.version' /home/$USER/watchdog/package.json)
#echo -e "${ARROW} ${CYAN}Watchdog ${GREEN}v$current_ver${CYAN} installed successful.${NC}"
string_limit_check_mark "Watchdog v$current_ver installed................................." "Watchdog ${GREEN}v$current_ver${CYAN} installed................................."
else
#echo -e "${ARROW} ${CYAN}Watchdog installion failed.${NC}"
string_limit_x_mark "Watchdog was not installed................................."
fi
else
#echo -e "${ARROW} ${CYAN}Watchdog installion failed.${NC}"
string_limit_x_mark "Watchdog was not installed................................."
fi
}

function mongodb_bootstrap(){

    echo -e ""
    echo -e "${ARROW} ${YELLOW}Restore mongodb datatable from bootstrap${NC}"
      
     DB_HIGHT=$(curl -s -m 10 https://fluxnodeservice.com/mongodb_bootstrap.json | jq -r '.block_height')
     if [[ "$DB_HIGHT" == "" ]]; then
         DB_HIGHT=$(curl -s -m 10 https://fluxnodeservice.com/mongodb_bootstrap.json | jq -r '.block_height')
     fi
    
    #BLOCKHIGHT=$(curl -s -m 6 http://"$WANIP":16127/explorer/scannedheight | jq '.data.generalScannedHeight')
    echo -e "${ARROW} ${CYAN}Bootstrap block height: ${GREEN}$DB_HIGHT${NC}"
    echo -e "${ARROW} ${CYAN}Downloading File: ${GREEN}$BOOTSTRAP_URL_MONGOD${NC}"
    wget --tries=5 $BOOTSTRAP_URL_MONGOD -q --show-progress 
    
    if [[ -f /home/$USER/$BOOTSTRAP_ZIPFILE_MONGOD ]]; then
    
        echo -e "${ARROW} ${CYAN}Unpacking...${NC}"
        tar xvf $BOOTSTRAP_ZIPFILE_MONGOD -C /home/$USER > /dev/null 2>&1 && sleep 1
        echo -e "${ARROW} ${CYAN}Importing mongodb datatable...${NC}"
        mongorestore --port 27017 --db zelcashdata /home/$USER/dump/zelcashdata --drop > /dev/null 2>&1
        echo -e "${ARROW} ${CYAN}Cleaning...${NC}"
        sudo rm -rf /home/$USER/dump > /dev/null 2>&1 && sleep 1
        sudo rm -rf $BOOTSTRAP_ZIPFILE_MONGOD > /dev/null 2>&1  && sleep 1


        BLOCKHIGHT_AFTER_BOOTSTRAP=$(mongoexport -d zelcashdata -c scannedheight  --jsonArray --pretty --quiet | jq -r .[].generalScannedHeight)
        echo -e ${ARROW} ${CYAN}Node block height after restored: ${GREEN}$BLOCKHIGHT_AFTER_BOOTSTRAP${NC}
		
     else
     
          echo -e "${ARROW} ${RED}MongoDB bootstrap server offline...try again later use option 5${NC}"   
     fi
     
        echo -e ""
    
    #if [[ "$BLOCKHIGHT_AFTER_BOOTSTRAP" -ge  "$DB_HIGHT" ]]; then
      #echo -e "${ARROW} ${CYAN}Mongo bootstrap installed successful.${NC}"
      #echo -e ""
   # else
     # echo -e "${ARROW} ${CYAN}Mongo bootstrap installation failed.${NC}"
     # echo -e ""
   # fi
  
}

function wipe_clean() {
    echo -e "${ARROW} ${YELLOW}Removing any instances of FluxNode${NC}"
    apt_number=$(ps aux | grep 'apt' | wc -l)
    
    if [[ "$apt_number" > 1 ]]; then
    
        sudo killall apt > /dev/null 2>&1
        sudo killall apt-get > /dev/null 2>&1
	sudo dpkg --configure -a > /dev/null 2>&1
	
    fi
    
    echo -e "${ARROW} ${CYAN}Stopping all services and running processes...${NC}"
    
    # NEW CLEAN_UP
    
    sudo killall nano > /dev/null 2>&1
    $COIN_CLI stop > /dev/null 2>&1 && sleep 2
    sudo systemctl stop $COIN_NAME > /dev/null 2>&1 && sleep 2
    sudo killall -s SIGKILL $COIN_DAEMON > /dev/null 2>&1 && sleep 2
    $BENCH_CLI stop > /dev/null 2>&1 && sleep 2
    sudo killall -s SIGKILL $BENCH_NAME > /dev/null 2>&1 && sleep 1
    sudo fuser -k 16127/tcp > /dev/null 2>&1 && sleep 1
    sudo fuser -k 16125/tcp > /dev/null 2>&1 && sleep 1
    sudo rm -rf /usr/bin/flux* > /dev/null 2>&1 && sleep 1
    
    echo -e "${ARROW} ${CYAN}Removing daemon && benchmark...${NC}"
    sudo apt-get remove $COIN_NAME $BENCH_NAME -y > /dev/null 2>&1 && sleep 1
    sudo apt-get purge $COIN_NAME $BENCH_NAME -y > /dev/null 2>&1 && sleep 1
    sudo apt-get autoremove -y > /dev/null 2>&1 && sleep 1
    sudo rm -rf /etc/apt/sources.list.d/zelcash.list > /dev/null 2>&1 && sleep 1
    tmux kill-server > /dev/null 2>&1 && sleep 1
    
    echo -e "${ARROW} ${CYAN}Removing PM2...${NC}"
    pm2 del zelflux > /dev/null 2>&1 && sleep 1
    pm2 del flux > /dev/null 2>&1 && sleep 1
    pm2 del watchdog > /dev/null 2>&1 && sleep 1
    pm2 save > /dev/null 2>&1
    pm2 unstartup > /dev/null 2>&1 && sleep 1
    pm2 flush > /dev/null 2>&1 && sleep 1
    pm2 save > /dev/null 2>&1 && sleep 1
    pm2 kill > /dev/null 2>&1  && sleep 1
    npm remove pm2 -g > /dev/null 2>&1 && sleep 1
    
    echo -e "${ARROW} ${CYAN}Removing others files and scripts...${NC}"
    sudo rm -rf watchgod > /dev/null 2>&1 && sleep 1
    sudo rm -rf $BENCH_DIR_LOG && sleep 1
      
    #FILE OF OLD ZEL NODE
    sudo rm -rf /etc/logrotate.d/mongolog > /dev/null 2>&1
    sudo rm -rf /etc/logrotate.d/zeldebuglog > /dev/null 2>&1
    rm update.sh > /dev/null 2>&1
    rm restart_zelflux.sh > /dev/null 2>&1
    rm zelnodeupdate.sh > /dev/null 2>&1
    rm start.sh > /dev/null 2>&1
    rm update-zelflux.sh > /dev/null 2>&1  
    sudo systemctl stop zelcash > /dev/null 2>&1 && sleep 2
    zelcash-cli stop > /dev/null 2>&1 && sleep 2
    sudo killall -s SIGKILL zelcashd > /dev/null 2>&1
    zelbench-cli stop > /dev/null 2>&1
    sudo killall -s SIGKILL zelbenchd > /dev/null 2>&1
    sudo rm /usr/local/bin/zel* > /dev/null 2>&1 && sleep 1
    sudo apt-get purge zelcash zelbench -y > /dev/null 2>&1 && sleep 1
    sudo apt-get autoremove -y > /dev/null 2>&1 && sleep 1
    sudo rm /etc/apt/sources.list.d/zelcash.list > /dev/null 2>&1 && sleep 1
    sudo rm -rf zelflux  > /dev/null 2>&1 && sleep 1
    #sudo rm -rf ~/.zelcash/determ_zelnodes ~/.zelcash/sporks ~/$CONFIG_DIR/database ~/.zelcash/blocks ~/.zelcashchainstate  > /dev/null 2>&1 && sleep 1
    #sudo rm -rf ~/.zelcash  > /dev/null 2>&1 && sleep 1
    sudo rm -rf .zelbenchmark  > /dev/null 2>&1 && sleep 1
    sudo rm -rf .fluxbenchmark  > /dev/null 2>&1 && sleep 1
    sudo rm -rf /home/$USER/stop_zelcash_service.sh > /dev/null 2>&1
    sudo rm -rf /home/$USER/start_zelcash_service.sh > /dev/null 2>&1
    
    if [[ -d /home/$USER/.zelcash  ]]; then
    
      echo -e "${ARROW} ${CYAN}Moving ~/.zelcash to ~/.flux${NC}"  
      #echo -e "${ARROW} ${CYAN}Renaming zelcash.conf to flux.conf${NC}"  
      sudo mv /home/$USER/.zelcash /home/$USER/.flux > /dev/null 2>&1 && sleep 1
      sudo mv /home/$USER/.flux/zelcash.conf /home/$USER/.flux/flux.conf > /dev/null 2>&1 && sleep 1   
        
    fi
   
    
 if [[ -d /home/$USER/$CONFIG_DIR ]]; then
 
    config_veryfity
    
    if [[ -z "$use_old_chain" ]]; then
    
      if [[ "$SKIP_OLD_CHAIN" == "0" ]]; then       
    
        if  ! whiptail --yesno "Would you like to use old chain from Flux daemon config directory?" 8 60; then
        echo -e "${ARROW} ${CYAN}Removing Flux daemon config directory...${NC}"
        sudo rm -rf ~/$CONFIG_DIR/determ_zelnodes ~/$CONFIG_DIR/sporks ~/$CONFIG_DIR/database ~/$CONFIG_DIR/blocks ~/$CONFIG_DIR/chainstate && sleep 2
        sudo rm -rf /home/$USER/$CONFIG_DIR  > /dev/null 2>&1 && sleep 2
    
        else
      
            BOOTSTRAP_SKIP="1"
	    sudo rm -rf /home/$USER/$CONFIG_DIR/fee_estimates.dat 
	    sudo rm -rf /home/$USER/$CONFIG_DIR/peers.dat && sleep 1
	    sudo rm -rf /home/$USER/$CONFIG_DIR/zelnode.conf 
	    sudo rm -rf /home/$USER/$CONFIG_DIR/zelnodecache.dat && sleep 1
	    sudo rm -rf /home/$USER/$CONFIG_DIR/zelnodepayments.dat
	    sudo rm -rf /home/$USER/$CONFIG_DIR/db.log
	    sudo rm -rf /home/$USER/$CONFIG_DIR/debug.log && sleep 1
	    sudo rm -rf /home/$USER/$CONFIG_DIR/flux.conf && sleep 1
	    sudo rm -rf /home/$USER/$CONFIG_DIR/database && sleep 1
	    sudo rm -rf /home/$USER/$CONFIG_DIR/sporks && sleep 1
        fi 
	
     else
     
       echo -e "${ARROW} ${CYAN}Removing Flux daemon config directory...${NC}"
       sudo rm -rf ~/$CONFIG_DIR/determ_zelnodes ~/$CONFIG_DIR/sporks ~/$CONFIG_DIR/database ~/$CONFIG_DIR/blocks ~/$CONFIG_DIR/chainstate && sleep 2
       sudo rm -rf /home/$USER/$CONFIG_DIR  > /dev/null 2>&1 && sleep 2
     
     fi
    
    
    else
    
    if [[ "$use_old_chain" == "1" ]]; then
    
      BOOTSTRAP_SKIP="1"
      sudo rm -rf /home/$USER/$CONFIG_DIR/fee_estimates.dat 
      sudo rm -rf /home/$USER/$CONFIG_DIR/peers.dat && sleep 1
      sudo rm -rf /home/$USER/$CONFIG_DIR/zelnode.conf 
      sudo rm -rf /home/$USER/$CONFIG_DIR/zelnodecache.dat && sleep 1
      sudo rm -rf /home/$USER/$CONFIG_DIR/zelnodepayments.dat
      sudo rm -rf /home/$USER/$CONFIG_DIR/db.log
      sudo rm -rf /home/$USER/$CONFIG_DIR/debug.log && sleep 1
      sudo rm -rf /home/$USER/$CONFIG_DIR/flux.conf && sleep 1
      sudo rm -rf /home/$USER/$CONFIG_DIR/database && sleep 1
      sudo rm -rf /home/$USER/$CONFIG_DIR/sporks && sleep 1
    
    else
    
      echo -e "${ARROW} ${CYAN}Removing Flux daemon config directory...${NC}"
      sudo rm -rf ~/$CONFIG_DIR/determ_zelnodes ~/$CONFIG_DIR/sporks ~/$CONFIG_DIR/database ~/$CONFIG_DIR/blocks ~/$CONFIG_DIR/chainstate && sleep 2
      sudo rm -rf /home/$USER/$CONFIG_DIR  > /dev/null 2>&1 && sleep 2
      
    
    fi
    
    fi
fi

    sudo rm -rf /home/$USER/watchdog > /dev/null 2>&1
    sudo rm -rf /home/$USER/stop_daemon_service.sh > /dev/null 2>&1
    sudo rm -rf /home/$USER/start_daemon_service.sh > /dev/null 2>&1
    echo -e ""
  
  echo -e "${ARROW} ${YELLOW}Checking firewall status...${NC}" && sleep 1
if [[ $(sudo ufw status | grep "Status: active") ]]; then
 # then
 #  if [[ -z "$firewall_disable" ]]; then    
    #  if   whiptail --yesno "Firewall is active and enabled. Do you want disable it during install process?<Yes>(Recommended)" 8 60; then
         sudo ufw disable > /dev/null 2>&1
	 echo -e "${ARROW} ${CYAN}Firewall status: ${RED}Disabled${NC}"
     # else	 
	# echo -e "${ARROW} ${CYAN}Firewall status: ${GREEN}Enabled${NC}"
    #  fi
   # else
    
     # if [[ "$firewall_disable" == "1" ]]; then
  	### sudo ufw disable > /dev/null 2>&1
	# echo -e "${ARROW} ${CYAN}Firewall status: ${RED}Disabled${NC}"
    #  else
        #echo -e "${ARROW} ${CYAN}Firewall status: ${GREEN}Enabled${NC}"
    #  fi
   # fi
    
 else
        echo -e "${ARROW} ${CYAN}Firewall status: ${RED}Disabled${NC}"
 fi
 
}

function spinning_timer() {
    animation=( ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏ )
    end=$((SECONDS+NUM))
    while [ $SECONDS -lt $end ];
    do
        for i in "${animation[@]}";
        do
	    echo -e ""
            echo -ne "${RED}\r\033[1A\033[0K$i ${CYAN}${MSG1}${NC}"
            sleep 0.1
	    
        done
    done
    echo -ne "${MSG2}"
}


function ssh_port() {
    
    if [[ -z "$ssh_port" ]]; then
    
    SSHPORT=$(grep -w Port /etc/ssh/sshd_config | sed -e 's/.*Port //')
   #  if ! whiptail --yesno "Detected you are using $SSHPORT for SSH is this correct?" 8 56; then
   #   SSHPORT=$(whiptail --inputbox "Please enter port you are using for SSH" 8 43 3>&1 1>&2 2>&3)
   #  echo -e "${ARROW} ${YELLOW}Using SSH port:${SEA} $SSHPORT${NC}" && sleep 1
   #  else
        echo -e "${ARROW} ${YELLOW}Using SSH port:${SEA} $SSHPORT${NC}" && sleep 1
   #  fi
    
    else   		
	pettern='^[0-9]+$'
	if [[ $ssh_port =~ $pettern ]] ; then
	  SSHPORT="$ssh_port"
	  echo -e "${ARROW} ${YELLOW}Using SSH port:${SEA} $SSHPORT${NC}" && sleep 1
	else
	 echo -e "${ARROW} ${CYAN}SSH port must be integer................[${X_MARK}${CYAN}]${NC}}"
	 echo
	 exit
	fi	   
    fi
}

function ip_confirm() {
    echo -e "${ARROW} ${YELLOW}Detecting IP address...${NC}"
    
    WANIP=$(curl --silent -m 15 https://api4.my-ip.io/ip | tr -dc '[:alnum:].')
    
    if [[ "$WANIP" == "" || "$WANIP" = *html* ]]; then
      WANIP=$(curl --silent -m 15 https://checkip.amazonaws.com | tr -dc '[:alnum:].')    
    fi  
      
    if [[ "$WANIP" == "" || "$WANIP" = *html* ]]; then
      WANIP=$(curl --silent -m 15 https://api.ipify.org | tr -dc '[:alnum:].')
    fi
      
        
    if [[ "$WANIP" == "" || "$WANIP" = *html* ]]; then
      	echo -e "${ARROW} ${CYAN}IP address could not be found, installation stopped .........[${X_MARK}${CYAN}]${NC}"
	echo
	exit
    fi
	 
	 
   string_limit_check_mark "Detected IP: $WANIP ................................." "Detected IP: ${GREEN}$WANIP${CYAN} ................................."
    
}

function create_swap() {

 if [[ -z "$swapon" ]]; then
    #echo -e "${YELLOW}Creating swap if none detected...${NC}" && sleep 1
    MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    gb=$(awk "BEGIN {print $MEM/1048576}")
    GB=$(echo "$gb" | awk '{printf("%d\n",$1 + 0.5)}')
    if [ "$GB" -lt 2 ]; then
        (( swapsize=GB*2 ))
        swap="$swapsize"G
    elif [[ $GB -ge 2 ]] && [[ $GB -le 16 ]]; then
        swap=4G
    elif [[ $GB -gt 16 ]] && [[ $GB -lt 32 ]]; then
        swap=2G
    fi
    if ! grep -q "swapfile" /etc/fstab; then
      #  if whiptail --yesno "No swapfile detected would you like to create one?" 8 54; then
            sudo fallocate -l "$swap" /swapfile > /dev/null 2>&1
            sudo chmod 600 /swapfile > /dev/null 2>&1
            sudo mkswap /swapfile > /dev/null 2>&1
            sudo swapon /swapfile > /dev/null 2>&1
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null 2>&1
            echo -e "${ARROW} ${YELLOW}Created ${SEA}${swap}${YELLOW} swapfile${NC}"
        else
            echo -e "${ARROW} ${YELLOW}Creating a swapfile skipped...${NC}"
       # fi
    fi
    
    else
    
     if [[ "$swapon" == "1" ]]; then
     
    MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    gb=$(awk "BEGIN {print $MEM/1048576}")
    GB=$(echo "$gb" | awk '{printf("%d\n",$1 + 0.5)}')
    if [ "$GB" -lt 2 ]; then
        (( swapsize=GB*2 ))
        swap="$swapsize"G
    elif [[ $GB -ge 2 ]] && [[ $GB -le 16 ]]; then
        swap=4G
    elif [[ $GB -gt 16 ]] && [[ $GB -lt 32 ]]; then
        swap=2G
    fi
    if ! grep -q "swapfile" /etc/fstab; then
            sudo fallocate -l "$swap" /swapfile > /dev/null 2>&1
            sudo chmod 600 /swapfile > /dev/null 2>&1
            sudo mkswap /swapfile > /dev/null 2>&1
            sudo swapon /swapfile > /dev/null 2>&1
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null 2>&1
            echo -e "${ARROW} ${YELLOW}Created ${SEA}${swap}${YELLOW} swapfile${NC}"
      else
            echo -e "${ARROW} ${YELLOW}Creating a swapfile skipped...${NC}"
      fi
    #fi
     
     fi
    
    
    fi
    sleep 2
}

function install_packages() {
    echo
    echo -e "${ARROW} ${YELLOW}Installing Packages...${NC}"
    
    if [[ $(lsb_release -d) = *Debian* ]] && [[ $(lsb_release -d) = *9* ]]; then
        sudo apt-get install dirmngr apt-transport-https -y > /dev/null 2>&1
    fi
    
    if ! dirmngr --v > /dev/null 2>&1; then
      sudo apt install dirmngr -y > /dev/null 2>&1
    fi
    
    sudo apt-get install software-properties-common ca-certificates -y > /dev/null 2>&1
    sudo apt-get update -y > /dev/null 2>&1
    sudo apt-get --with-new-pkgs upgrade -y > /dev/null 2>&1
    sudo apt-get install nano htop pwgen ufw figlet tmux jq zip gzip pv unzip git -y > /dev/null 2>&1
    sudo apt-get install build-essential libtool pkg-config -y > /dev/null 2>&1
    sudo apt-get install libc6-dev m4 g++-multilib -y > /dev/null 2>&1
    sudo apt-get install autoconf ncurses-dev python python-zmq -y > /dev/null 2>&1
    sudo apt-get install wget curl bc bsdmainutils automake fail2ban -y > /dev/null 2>&1
    sudo apt-get remove sysbench -y > /dev/null 2>&1
    echo -e "${ARROW} ${YELLOW}Packages complete...${NC}"
}

function create_conf() {

    echo -e "${ARROW} ${YELLOW}Creating Flux daemon config file...${NC}"
    if [ -f ~/$CONFIG_DIR/$CONFIG_FILE ]; then
        echo -e "${ARROW} ${CYAN}Existing conf file found backing up to $COIN_NAME.old ...${NC}"
        mv ~/$CONFIG_DIR/$CONFIG_FILE ~/$CONFIG_DIR/$COIN_NAME.old;
    fi
    
    RPCUSER=$(pwgen -1 8 -n)
    PASSWORD=$(pwgen -1 20 -n)

    if [[ "$IMPORT_ZELCONF" == "0" ]]
    then
    if [[ -z $zelnodeprivkey ]]; then
      zelnodeprivkey=$(whiptail --title "Flux daemon configuration" --inputbox "Enter your FluxNode Identity Key generated by your Zelcore" 8 72 3>&1 1>&2 2>&3)
    fi
    if [[ -z $zelnodeoutpoint ]]; then
      zelnodeoutpoint=$(whiptail --title "Flux daemon configuration" --inputbox "Enter your FluxNode collateral txid" 8 72 3>&1 1>&2 2>&3)
    fi
    if [[ -z $zelnodeindex ]]; then
      zelnodeindex=$(whiptail --title "Flux daemon configuration" --inputbox "Enter your FluxNode collateral output index usually a 0/1" 8 60 3>&1 1>&2 2>&3)
    fi


    if [ "x$PASSWORD" = "x" ]; then
        PASSWORD=${WANIP}-$(date +%s)
    fi
    mkdir ~/$CONFIG_DIR > /dev/null 2>&1
    touch ~/$CONFIG_DIR/$CONFIG_FILE
    cat << EOF > ~/$CONFIG_DIR/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$PASSWORD
rpcallowip=127.0.0.1
rpcallowip=172.18.0.1
rpcport=$RPCPORT
port=$PORT
zelnode=1
zelnodeprivkey=$zelnodeprivkey
zelnodeoutpoint=$zelnodeoutpoint
zelnodeindex=$zelnodeindex
server=1
daemon=1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
insightexplorer=1
experimentalfeatures=1
listen=1
externalip=$WANIP
bind=0.0.0.0
addnode=80.211.207.17
addnode=95.217.12.176
addnode=89.58.3.209
addnode=161.97.85.103
addnode=194.163.176.185
addnode=explorer.flux.zelcore.io
addnode=explorer.runonflux.io
addnode=explorer.zelcash.online
addnode=blockbook.runonflux.io
addnode=202.61.202.21
addnode=89.58.40.172
addnode=37.120.176.206
addnode=66.119.15.83
addnode=66.94.118.208
addnode=99.48.162.169
addnode=97.120.40.143
addnode=99.48.162.167
addnode=108.30.50.162
addnode=154.12.242.89
addnode=67.43.96.139
addnode=66.94.107.219
addnode=66.94.110.117
addnode=154.12.225.203
addnode=176.9.72.41
addnode=65.108.198.119
addnode=65.108.200.110
addnode=46.38.251.110
addnode=95.214.55.47
addnode=202.61.236.202
addnode=65.108.141.153
addnode=178.170.46.91
addnode=66.119.15.64
addnode=65.108.46.178
addnode=94.130.220.41
addnode=178.170.48.110
addnode=78.35.147.57
addnode=66.119.15.101
addnode=66.119.15.96
addnode=38.88.125.25
addnode=66.119.15.110
addnode=103.13.31.149
addnode=212.80.212.238
addnode=212.80.213.172
addnode=212.80.212.228
addnode=121.112.224.186
addnode=114.181.141.16
addnode=167.179.115.100
addnode=153.226.219.80
addnode=24.79.73.50
addnode=76.68.219.102
addnode=70.52.20.8
addnode=184.145.181.147
addnode=68.150.72.135
addnode=198.27.83.181
addnode=167.114.82.63
addnode=24.76.166.6
addnode=173.33.170.150
addnode=99.231.229.245
addnode=70.82.102.140
addnode=192.95.30.188
addnode=75.158.245.77
addnode=142.113.239.49
addnode=66.70.176.241
addnode=174.93.146.224
addnode=216.232.124.38
addnode=207.34.248.197
addnode=76.68.219.102
addnode=149.56.25.82
addnode=74.57.74.166
addnode=142.169.180.47
addnode=70.67.210.148
addnode=86.5.78.14
addnode=87.244.105.94
addnode=86.132.192.193
addnode=86.27.168.85
addnode=86.31.168.107
addnode=84.71.79.220
addnode=154.57.235.104
addnode=86.13.102.145
addnode=86.31.168.107
addnode=86.13.68.100
addnode=151.225.136.163
addnode=5.45.110.123
addnode=45.142.178.251
addnode=89.58.5.234
addnode=45.136.30.81
addnode=202.61.255.238
addnode=89.58.7.2
addnode=89.58.36.46
addnode=89.58.32.76
addnode=89.58.39.81
addnode=89.58.39.153
addnode=202.61.244.71
addnode=89.58.37.172
addnode=89.58.36.118
addnode=31.145.161.44
addnode=217.131.61.221
addnode=80.28.72.254
addnode=85.49.210.36
addnode=84.77.69.203
addnode=51.38.1.195
addnode=51.38.1.194
maxconnections=256
EOF
    sleep 2
    
 if [[ "$IMPORT_ZELID" == "0" ]]; then

        while true
        do
                if [[ -z $ZELID ]]; then
                  ZELID=$(whiptail --title "Flux Configuration" --inputbox "Enter your ZEL ID from ZelCore (Apps -> Zel ID (CLICK QR CODE)) " 8 72 3>&1 1>&2 2>&3)
                fi
                if [ $(printf "%s" "$ZELID" | wc -c) -eq "34" ] || [ $(printf "%s" "$ZELID" | wc -c) -eq "33" ]; then
                echo -e "${ARROW} ${CYAN}Zel ID is valid${CYAN}.........................[${CHECK_MARK}${CYAN}]${NC}"
                break
                else
                echo -e "${ARROW} ${CYAN}Zel ID is not valid try again...........[${X_MARK}${CYAN}]${NC}"
                sleep 4
                fi
        done
	
      #  if whiptail --yesno "Are you planning to run Kadena node? Please note that only Nimbus/Stratus nodes are allowed to run it. ( to get reward you still NEED INSTALL KadenaChainWebNode under Apps -> Local Apps section via FluxOS Web UI )" 10 90 3>&1 1>&2 2>&3; then
	
	    tier
	    if [[ "$kadena_possible" == "1" ]]; then
	
	      while true
                do
                    if [[ -z $KDA_A ]]; then
                      KDA_A=$(whiptail --inputbox "Node tier eligible to receive KDA rewards, what's your KDA address? Nothing else will be required on FluxOS regarding KDA." 8 85 3>&1 1>&2 2>&3)
                    fi
                    if [[ "$KDA_A" != "" && "$KDA_A" != *kadena* ]]; then
		    	
			echo -e "${ARROW} ${CYAN}Kadena address is valid.................[${CHECK_MARK}${CYAN}]${NC}"	
			KDA_A="kadena:$KDA_A?chainid=0"			    
                        sleep 2
			break
			
		    else	     
		        echo -e "${ARROW} ${CYAN}Kadena address is not valid.............[${X_MARK}${CYAN}]${NC}"
			sleep 2		     
		    fi
              done
	                 
           fi
	
 fi      
 
}



function flux_package() {
    sudo apt-get update -y > /dev/null 2>&1 && sleep 2
    echo -e "${ARROW} ${YELLOW}Flux Daemon && Benchmark installing...${NC}"
    sudo apt install $COIN_NAME $BENCH_NAME -y > /dev/null 2>&1 && sleep 2
    sudo chmod 755 $COIN_PATH/* > /dev/null 2>&1 && sleep 2
    integration_check
}

function install_daemon() {

   sudo rm /etc/apt/sources.list.d/zelcash.list > /dev/null 2>&1
   sudo rm /etc/apt/sources.list.d/flux.list > /dev/null 2>&1
   
   echo -e "${ARROW} ${YELLOW}Configuring daemon repository and importing public GPG Key${NC}" 
   sudo chown -R $USER:$USER /usr/share/keyrings > /dev/null 2>&1
   sudo chown -R $USER:$USER /home/$USER/.gnupg > /dev/null 2>&1
     
if [[ "$(lsb_release -cs)" == "xenial" ]]; then
   
     echo 'deb https://apt.runonflux.io/ '$(lsb_release -cs)' main' | sudo tee --append /etc/apt/sources.list.d/flux.list > /dev/null 2>&1  
     gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B69CA27A986265D > /dev/null 2>&1
     gpg --export 4B69CA27A986265D | sudo apt-key add - > /dev/null 2>&1    
     
     if ! gpg --list-keys Zel > /dev/null; then    
         gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys 4B69CA27A986265D > /dev/null 2>&1
         gpg --export 4B69CA27A986265D | sudo apt-key add - > /dev/null 2>&1   
     fi
        
     flux_package && sleep 2    
else
   
   gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B69CA27A986265D > /dev/null 2>&1
   gpg --export 4B69CA27A986265D | sudo apt-key add - > /dev/null 2>&1
   
   if ! gpg --list-keys Zel > /dev/null; then    
        gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys 4B69CA27A986265D > /dev/null 2>&1
        gpg --export 4B69CA27A986265D | sudo apt-key add - > /dev/null 2>&1   
   fi
   
   # cleaning 
   sudo rm /usr/share/keyrings/flux-archive-keyring.gpg > /dev/null 2>&1
   
   if [[ "$(lsb_release -cs)" == "impish" ]]; then
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/flux-archive-keyring.gpg] https://apt.runonflux.io/ focal main" | sudo tee /etc/apt/sources.list.d/flux.list  > /dev/null 2>&1
   else
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/flux-archive-keyring.gpg] https://apt.runonflux.io/ focal main" | sudo tee /etc/apt/sources.list.d/flux.list  > /dev/null 2>&1
   fi
   
   
   # downloading key && save it as keyring  
   gpg --no-default-keyring --keyring /usr/share/keyrings/flux-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4B69CA27A986265D > /dev/null 2>&1

   if ! gpg -k --keyring /usr/share/keyrings/flux-archive-keyring.gpg Zel > /dev/null 2>&1; then
      echo -e "${YELLOW}First attempt to retrieve keys failed will try a different keyserver.${NC}"
      sudo rm /usr/share/keyrings/zelcash-archive-keyring.gpg > /dev/null 2>&1
      gpg --no-default-keyring --keyring /usr/share/keyrings/flux-archive-keyring.gpg --keyserver hkp://na.pool.sks-keyservers.net:80 --recv-keys 4B69CA27A986265D > /dev/null 2>&1
   fi


   if ! gpg -k --keyring /usr/share/keyrings/flux-archive-keyring.gpg Zel > /dev/null 2>&1; then
      echo -e "${YELLOW}Last keyserver also failed will try one last keyserver.${NC}"
      sudo rm /usr/share/keyrings/flux-archive-keyring.gpg > /dev/null 2>&1
      gpg --no-default-keyring --keyring /usr/share/keyrings/flux-archive-keyring.gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys 4B69CA27A986265D > /dev/null 2>&1
   fi


   if gpg -k --keyring /usr/share/keyrings/flux-archive-keyring.gpg Zel > /dev/null 2>&1; then
   
    flux_package && sleep 2
    
   else
   
     echo
     echo -e "${WORNING} ${RED}Importing public GPG Key failed...${NC}"
     echo -e "${WORNING} ${CYAN}Installation stopped...${NC}"
     echo
     exit
     
   fi
   
fi


}



function zk_params() {
    echo -e "${ARROW} ${YELLOW}Installing zkSNARK params...${NC}"
    bash flux-fetch-params.sh > /dev/null 2>&1 && sleep 2
    sudo chown -R $USER:$USER /home/$USER  > /dev/null 2>&1
}

function bootstrap() {


    if ! wget --version > /dev/null 2>&1 ; then
       sudo apt install -y wget > /dev/null 2>&1 && sleep 2
    fi
   
    if ! wget --version > /dev/null 2>&1 ; then
         echo -e "${WORNING} ${CYAN}Wget not installed, operation aborted.. ${NC}" && sleep 1
         echo -e ""
         return 1
    fi

    bootstrap_geolocation
    bootstrap_server $continent
    
    if [[ "$Server_offline" == "1" ]]; then
     echo -e "${WORNING} ${CYAN}All Bootstrap server offline, operation aborted.. ${NC}" && sleep 1
     echo -e ""
     return 1
    fi
       
    bootstrap_index=$((${#richable[@]}-1))
    r=$(shuf -i 0-$bootstrap_index -n 1)
    indexb=${richable[$r]}
    
    BOOTSTRAP_ZIP="http://cdn-$indexb.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.tar.gz"
    BOOTSTRAP_ZIPFILE="${BOOTSTRAP_ZIP##*/}"
    
    echo -e ""
    echo -e "${ARROW} ${YELLOW}Restore daemon chain from bootstrap${NC}"
    
    if [[ -z "$bootstrap_url" ]]; then

      
        if [[ -e ~/$CONFIG_DIR/blocks ]] && [[ -e ~/$CONFIG_DIR/chainstate ]]; then
            echo -e "${ARROW} ${CYAN}Cleaning...${NC}"
            rm -rf ~/$CONFIG_DIR/blocks ~/$CONFIG_DIR/chainstate ~/$CONFIG_DIR/determ_zelnodes
	
        fi


        if [ -f "/home/$USER/$BOOTSTRAP_ZIPFILE" ]; then		   
	
            if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
	
                echo -e "${ARROW} ${YELLOW}Local bootstrap file detected...${NC}"
	        echo -e "${ARROW} ${YELLOW}Checking if zip file is corrupted...${NC}"
                if unzip -t $BOOTSTRAP_ZIPFILE | grep 'No errors' > /dev/null 2>&1
                then
                    echo -e "${ARROW} ${CYAN}Bootstrap zip file is valid.............[${CHECK_MARK}${CYAN}]${NC}"
                else
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   echo -e "${ARROW} ${CYAN}Bootstrap file is corrupted.............[${X_MARK}${CYAN}]${NC}"
                   rm -rf $BOOTSTRAP_ZIPFILE
               fi
	    
	    else	    
                check_tar "/home/$USER/$BOOTSTRAP_ZIPFILE"
	    fi
	    
	fi


        if [ -f "/home/$USER/$BOOTSTRAP_ZIPFILE" ]; then
	
	
            if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
	        echo -e "${ARROW} ${YELLOW}Unpacking wallet bootstrap please be patient...${NC}"
                unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1
            else
                tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR"
                sleep 2  
	    fi
	
        else

            if [[ -z $CHOICE ]]; then
              CHOICE=$(
              whiptail --title "FLUXNODE INSTALLATION" --menu "Choose a method how to get bootstrap file" 10 47 2  \
                  "1)" "Download from source build in script" \
                  "2)" "Download from own source" 3>&2 2>&1 1>&3
              )
            fi

            case $CHOICE in
	    "1)")   
	        
	        DB_HIGHT=$(curl -sSL -m 10 http://cdn-$indexb.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.json | jq -r '.block_height' 2>/dev/null)
		if [[ "$DB_HIGHT" == "" ]]; then
		  DB_HIGHT=$(curl -sSL -m 10 http://cdn-$indexb.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.json | jq -r '.block_height' 2>/dev/null)
		fi
		
		
		
		
		echo -e "${ARROW} ${CYAN}Flux daemon bootstrap height: ${GREEN}$DB_HIGHT${NC}"
	 	echo -e "${ARROW} ${YELLOW}Downloading File: ${GREEN}$BOOTSTRAP_ZIP ${NC}"
       		wget --tries 5 -O $BOOTSTRAP_ZIPFILE $BOOTSTRAP_ZIP -q --show-progress
	        tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR" 
		sleep 2
        	#unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1


	    ;;
	    "2)")  
      if [[ -z $BOOTSTRAP_ZIP ]]; then
        BOOTSTRAP_ZIP="$(whiptail --title "Flux daemon bootstrap setup" --inputbox "Enter your URL (zip, tar.gz)" 8 72 3>&1 1>&2 2>&3)"
      fi
		echo -e "${ARROW} ${YELLOW}Downloading File: ${GREEN}$BOOTSTRAP_ZIP ${NC}"		
		BOOTSTRAP_ZIPFILE="${BOOTSTRAP_ZIP##*/}"
		wget --tries 5 -O $BOOTSTRAP_ZIPFILE $BOOTSTRAP_ZIP -q --show-progress
		
	        if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
 		    echo -e "${ARROW} ${YELLOW}Unpacking wallet bootstrap please be patient...${NC}"
                    unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1
		else	       
		    tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR"
		    sleep 2
		fi
		#echo -e "${ARROW} ${YELLOW}Unpacking wallet bootstrap please be patient...${NC}"
		#unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1
	    ;;
            esac

        fi

    else

        if [[ -e ~/$CONFIG_DIR/blocks ]] && [[ -e ~/$CONFIG_DIR/chainstate ]]; then
            echo -e "${ARROW} ${CYAN}Cleaning...${NC}"
            rm -rf ~/$CONFIG_DIR/blocks ~/$CONFIG_DIR/chainstate ~/$CONFIG_DIR/determ_zelnodes
        fi

        if [ -f "/home/$USER/$BOOTSTRAP_ZIPFILE" ]; then
	
            if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
	
                echo -e "${ARROW} ${YELLOW}Local bootstrap file detected...${NC}"
	        echo -e "${ARROW} ${YELLOW}Checking if zip file is corrupted...${NC}"
                if unzip -t $BOOTSTRAP_ZIPFILE | grep 'No errors' > /dev/null 2>&1
                then
                    echo -e "${ARROW} ${CYAN}Bootstrap zip file is valid.............[${CHECK_MARK}${CYAN}]${NC}"
                else
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   printf '\e[A\e[K'
                   echo -e "${ARROW} ${CYAN}Bootstrap file is corrupted.............[${X_MARK}${CYAN}]${NC}"
                   rm -rf $BOOTSTRAP_ZIPFILE
               fi
	    
	    else	    
                check_tar "/home/$USER/$BOOTSTRAP_ZIPFILE"
	    fi
	    
	fi


        if [[ "$bootstrap_url" == "0" ]]; then

            if [ -f "/home/$USER/$BOOTSTRAP_ZIPFILE" ]; then

                if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
	            echo -e "${ARROW} ${YELLOW}Unpacking wallet bootstrap please be patient...${NC}"
                    unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1
                else
                    tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR"
                    sleep 2  
	        fi
		
            else
	    
	        DB_HIGHT=$(curl -sSL -m 10 http://cdn-$indexb.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.json | jq -r '.block_height' 2>/dev/null)
		if [[ "$DB_HIGHT" == "" ]]; then
		  DB_HIGHT=$(curl -sSL -m 10 http://cdn-$indexb.runonflux.io/apps/fluxshare/getfile/flux_explorer_bootstrap.json | jq -r '.block_height' 2>/dev/null)
		fi
		
		
		echo -e "${ARROW} ${CYAN}Flux daemon bootstrap height: ${GREEN}$DB_HIGHT${NC}"
                echo -e "${ARROW} ${YELLOW}Downloading File: ${GREEN}$BOOTSTRAP_ZIP ${NC}"
                wget --tries 5 -O $BOOTSTRAP_ZIPFILE $BOOTSTRAP_ZIP -q --show-progress
		tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR" 
		sleep 2

	    fi
	    
        else
	
            if [ -f "/home/$USER/$BOOTSTRAP_ZIPFILE" ]; then
                tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR" 
		sleep 2
            else
                BOOTSTRAP_ZIP="$bootstrap_url"
                echo -e "${ARROW} ${YELLOW}Downloading File: ${GREEN}$BOOTSTRAP_ZIP ${NC}"           
		BOOTSTRAP_ZIPFILE="${BOOTSTRAP_ZIP##*/}"
		wget --tries 5 -O $BOOTSTRAP_ZIPFILE $BOOTSTRAP_ZIP -q --show-progress
		
	        if [[ "$BOOTSTRAP_ZIPFILE" == *".zip"* ]]; then
 		    echo -e "${ARROW} ${YELLOW}Unpacking wallet bootstrap please be patient...${NC}"
                    unzip -o $BOOTSTRAP_ZIPFILE -d /home/$USER/$CONFIG_DIR > /dev/null 2>&1
		else	       
		    tar_file_unpack "/home/$USER/$BOOTSTRAP_ZIPFILE" "/home/$USER/$CONFIG_DIR"
		    sleep 2
		fi	
		
            fi
        fi
    fi

    if [[ -z "$bootstrap_zip_del" ]]; then
      #  if whiptail --yesno "Would you like remove bootstrap archive file?" 8 60; then
            rm -rf $BOOTSTRAP_ZIPFILE
      #  fi
    else

        if [[ "$bootstrap_zip_del" == "1" ]]; then
          rm -rf $BOOTSTRAP_ZIPFILE
        fi
  
    fi
     
    


}


function create_service_scripts() {

#echo -e "${ARROW} ${YELLOW}Creating Flux daemon service scripts...${NC}" && sleep 1
sudo touch /home/$USER/start_daemon_service.sh
sudo chown $USER:$USER /home/$USER/start_daemon_service.sh
    cat <<'EOF' > /home/$USER/start_daemon_service.sh
#!/bin/bash

#color codes
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'
#emoji codes
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
WORNING="${RED}\xF0\x9F\x9A\xA8${NC}"

sleep 2
echo -e "${BOOK} ${CYAN}Pre-start process starting...${NC}"
echo -e "${BOOK} ${CYAN}Checking if benchmark or daemon is running${NC}"
bench_status_pind=$(pgrep fluxbenchd)
daemon_status_pind=$(pgrep fluxd)
if [[ "$bench_status_pind" == "" && "$daemon_status_pind" == "" ]]; then
echo -e "${BOOK} ${CYAN}No running instance detected...${NC}"
else
if [[ "$bench_status_pind" != "" ]]; then
echo -e "${WORNING} Running benchmark process detected${NC}"
echo -e "${WORNING} Killing benchmark...${NC}"
sudo killall -9 fluxbenchd > /dev/null 2>&1  && sleep 2
fi
if [[ "$daemon_status_pind" != "" ]]; then
echo -e "${WORNING} Running daemon process detected${NC}"
echo -e "${WORNING} Killing daemon...${NC}"
sudo killall -9 fluxd > /dev/null 2>&1  && sleep 2
fi
sudo fuser -k 16125/tcp > /dev/null 2>&1 && sleep 1
fi

bench_status_pind=$(pgrep zelbenchd)
daemon_status_pind=$(pgrep zelcashd)
if [[ "$bench_status_pind" == "" && "$daemon_status_pind" == "" ]]; then
echo -e "${BOOK} ${CYAN}No running instance detected...${NC}"
else
if [[ "$bench_status_pind" != "" ]]; then
echo -e "${WORNING} Running benchmark process detected${NC}"
echo -e "${WORNING} Killing benchmark...${NC}"
sudo killall -9 zelbenchd > /dev/null 2>&1  && sleep 2
fi
if [[ "$daemon_status_pind" != "" ]]; then
echo -e "${WORNING} Running daemon process detected${NC}"
echo -e "${WORNING} Killing daemon...${NC}"
sudo killall -9 zelcashd > /dev/null 2>&1  && sleep 2
fi
sudo fuser -k 16125/tcp > /dev/null 2>&1 && sleep 1
fi

if [[ -f /usr/local/bin/fluxd ]]; then
bash -c "fluxd"
exit
else
bash -c "zelcashd"
exit
fi
EOF


sudo touch /home/$USER/stop_daemon_service.sh
sudo chown $USER:$USER /home/$USER/stop_daemon_service.sh
    cat <<'EOF' > /home/$USER/stop_daemon_service.sh
#!/bin/bash
if [[ -f /usr/local/bin/flux-cli ]]; then
bash -c "flux-cli stop"
else
bash -c "zelcash-cli stop"
fi
exit
EOF

sudo chmod +x /home/$USER/stop_daemon_service.sh
sudo chmod +x /home/$USER/start_daemon_service.sh

}

function create_service() {
    echo -e "${ARROW} ${YELLOW}Creating Flux daemon service...${NC}" && sleep 1
    sudo touch /etc/systemd/system/zelcash.service
    sudo chown $USER:$USER /etc/systemd/system/zelcash.service
    cat << EOF > /etc/systemd/system/zelcash.service
[Unit]
Description=Flux daemon service
After=network.target
[Service]
Type=forking
User=$USER
Group=$USER
ExecStart=/home/$USER/start_daemon_service.sh
ExecStop=-/home/$USER/stop_daemon_service.sh
Restart=always
RestartSec=10
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=15s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
    sudo chown root:root /etc/systemd/system/zelcash.service
    sudo systemctl daemon-reload
}

function basic_security() {
    echo -e "${ARROW} ${YELLOW}Configuring firewall and enabling fail2ban...${NC}"
    #sudo ufw allow 16124/tcp > /dev/null 2>&1
    sudo ufw allow "$SSHPORT"/tcp > /dev/null 2>&1
    #sudo ufw allow "$PORT"/tcp > /dev/null 2>&1
    sudo ufw logging on > /dev/null 2>&1
    sudo ufw default deny incoming > /dev/null 2>&1
    
    sudo ufw allow out from any to any port 123  > /dev/null 2>&1
    sudo ufw allow out to any port 80 > /dev/null 2>&1
    sudo ufw allow out to any port 443 > /dev/null 2>&1
    sudo ufw allow out to any port 53 > /dev/null 2>&1
    #sudo ufw allow out to any port 16124 > /dev/null 2>&1
    #sudo ufw allow out to any port 16125 > /dev/null 2>&1
    #sudo ufw allow out to any port 16127 > /dev/null 2>&1
    #sudo ufw allow from any to any port 16127 > /dev/null 2>&1
    
    #FluxOS communication
    sudo ufw allow 16100:16199/tcp > /dev/null 2>&1
    ##
    
    sudo ufw default deny outgoing > /dev/null 2>&1
    sudo ufw limit OpenSSH > /dev/null 2>&1
    echo "y" | sudo ufw enable > /dev/null 2>&1
    sudo ufw reload > /dev/null 2>&1
    sudo systemctl enable fail2ban > /dev/null 2>&1
    sudo systemctl start fail2ban > /dev/null 2>&1
}

function pm2_install(){

    echo -e "${ARROW} ${YELLOW}PM2 installing...${NC}"
    npm install pm2@latest -g > /dev/null 2>&1
    
    if pm2 -v > /dev/null 2>&1
    then
     	echo -e "${ARROW} ${YELLOW}Configuring PM2...${NC}"
   	pm2 startup systemd -u $USER > /dev/null 2>&1
   	sudo env PATH=$PATH:/home/$USER/.nvm/versions/node/$(node -v)/bin pm2 startup systemd -u $USER --hp /home/$USER > /dev/null 2>&1
	

   	#pm2 start ~/zelflux/start.sh --name zelflux > /dev/null 2>&1
    	#pm2 save > /dev/null 2>&1
	
	
	pm2 install pm2-logrotate > /dev/null 2>&1
	pm2 set pm2-logrotate:max_size 6M > /dev/null 2>&1
	pm2 set pm2-logrotate:retain 6 > /dev/null 2>&1
    	pm2 set pm2-logrotate:compress true > /dev/null 2>&1
    	pm2 set pm2-logrotate:workerInterval 3600 > /dev/null 2>&1
    	pm2 set pm2-logrotate:rotateInterval '0 12 * * 0' > /dev/null 2>&1
	
	source ~/.bashrc
	#echo -e "${ARROW} ${CYAN}PM2 version: ${GREEN}v$(pm2 -v)${CYAN} installed${NC}"
	 string_limit_check_mark "PM2 v$(pm2 -v) installed................................." "PM2 ${GREEN}v$(pm2 -v)${CYAN} installed................................."
	 echo
    else  	 
	 string_limit_x_mark "PM2 was not installed................................."
	 echo
    fi 

}

function start_daemon() {

    sudo systemctl enable zelcash.service > /dev/null 2>&1
    sudo systemctl start zelcash > /dev/null 2>&1
    
    #NUM='300'
    #MSG1='Starting daemon & syncing with chain please be patient this will take about 5 min...'
    #MSG2=''
    #spinning_timer
    

    
    x=1  
    while [ $x -le 6 ]
     do
     
       NUM='300'
       MSG1='Starting daemon & syncing with chain please be patient this will take about 5 min...'
       MSG2=''
       spinning_timer 
       
       chain_check=$($COIN_CLI getinfo  2>&1 >/dev/null | grep "Activating" | wc -l)   
       if [[ "$chain_check" == "1" ]]; then
             echo -e ""
             echo -e "${ARROW} ${CYAN}Activating best chain detected....Awaiting increased for next 5min${NC}"
       fi
        
       if [[ "$($COIN_CLI  getinfo 2>/dev/null  | jq -r '.version' 2>/dev/null)" != "" ]]; then
          break
       fi
       
       if [[ "$x" -gt 6 ]]; then
         echo -e "${ARROW} ${CYAN}Maximum timeout exceeded...${NC}"
	 break
       fi
       
        x=$(( $x + 1 ))
       
     done
    
    
    
    
    if [[ "$($COIN_CLI  getinfo 2>/dev/null  | jq -r '.version' 2>/dev/null)" != "" ]]; then
    # if $COIN_DAEMON > /dev/null 2>&1; then
        
        NUM='2'
        MSG1='Getting info...'
        MSG2="${CYAN}.........................[${CHECK_MARK}${CYAN}]${NC}"
        spinning_timer
        echo && echo
	
	
	daemon_version=$($COIN_CLI getinfo | jq -r '.version')
	string_limit_check_mark "Flux daemon v$daemon_version installed................................." "Flux daemon ${GREEN}v$daemon_version${CYAN} installed................................."
	#echo -e "Zelcash version: ${GREEN}v$zelcash_version${CYAN} installed................................."
	bench_version=$($BENCH_CLI getinfo | jq -r '.version')
	string_limit_check_mark "Flux benchmark v$bench_version installed................................." "Flux benchmark ${GREEN}v$bench_version${CYAN} installed................................."
	#echo -e "${ARROW} ${CYAN}Zelbench version: ${GREEN}v$zelbench_version${CYAN} installed${NC}"
	echo
	pm2_install
	#zelbench-cli stop > /dev/null 2>&1  && sleep 2
    else
        echo
        echo -e "${WORNING} ${RED}Something is not right the daemon did not start or still loading...${NC}"
	
	if [[ -f /home/$USER/$CONFIG_DIR/debug.log ]]; then
	  error_line=$(egrep -a --color 'Error:' /home/$USER/$CONFIG_DIR/debug.log | tail -1 | sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}.//')	  
	     if [[ "$error_line" != "" ]]; then	  
	       echo -e "${WORNING} ${CYAN}Last error from ~/$CONFIG_DIR/debug.log: ${NC}"
	       echo -e "${WORNING} ${CYAN}$error_line${NC}"
	       echo
	       exit
	     fi  	       
        fi
	
	
	if whiptail --yesno "Something is not right the daemon did not start or still loading....\nWould you like continue the installation (make sure that flux daemon working) Y/N?" 8 90; then
       
          echo -e "${ARROW} ${CYAN}Problem with daemon noticed but user want continue installation...  ${NC}"
	  echo -n ""

	else
	
	  echo -e "${WORNING} ${RED}Installation stopped by user...${NC}"
	  echo -n ""
	  exit

	fi

		
    fi
}

function log_rotate() {
    echo -e "${ARROW} ${YELLOW}Configuring log rotate function for $1 logs...${NC}"
    sleep 1
    if [ -f /etc/logrotate.d/$2 ]; then
        sudo rm -rf /etc/logrotate.d/$2
        sleep 2
    fi

    sudo touch /etc/logrotate.d/$2
    sudo chown $USER:$USER /etc/logrotate.d/$2
    cat << EOF > /etc/logrotate.d/$2
$3 {
  compress
  copytruncate
  missingok
  $4
  rotate $5
}
EOF
    sudo chown root:root /etc/logrotate.d/$2
}

function install_process() {
 
    echo -e "${ARROW} ${YELLOW}Configuring firewall...${NC}"
    sudo ufw allow $ZELFRONTPORT/tcp > /dev/null 2>&1
    sudo ufw allow $LOCPORT/tcp > /dev/null 2>&1
    sudo ufw allow $ZELNODEPORT/tcp > /dev/null 2>&1
    #sudo ufw allow $MDBPORT/tcp > /dev/null 2>&1

    echo -e "${ARROW} ${YELLOW}Configuring service repositories...${NC}"
    
    sudo rm /etc/apt/sources.list.d/mongodb*.list > /dev/null 2>&1
    sudo rm /usr/share/keyrings/mongodb-archive-keyring.gpg > /dev/null 2>&1 
    
    if [[ $(lsb_release -cs) = *jammy* ]]; then    
      curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-archive-keyring.gpg > /dev/null 2>&1
    else
      curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor | sudo tee /usr/share/keyrings/mongodb-archive-keyring.gpg > /dev/null 2>&1
    fi

    if [[ $(lsb_release -d) = *Debian* ]]; then 

        
        if [[ $(lsb_release -cs) = *stretch* || $(lsb_release -cs) = *buster* ]]; then
           echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/4.4 main" 2> /dev/null | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1        
        else
	   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" 2> /dev/null | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1	
        fi


    elif [[ $(lsb_release -d) = *Ubuntu* ]]; then 


        if [[ $(lsb_release -cs) = *focal* || $(lsb_release -cs) = *bionic* || $(lsb_release -cs) = *xenial* ]]; then
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/4.4 multiverse" 2> /dev/null | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1       
        elif [[ $(lsb_release -cs) = *jammy* ]]; then
	  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" 2> /dev/null | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list > /dev/null 2>&1  
	else
	    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" 2> /dev/null | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1  
        fi

    else

      echo -e "${WORNING} ${RED}OS type not supported..${NC}"
      echo -e "${WORNING} ${CYAN}Installation stopped...${NC}"
      echo
      exit    

    fi
    
    
    if ! sysbench --version > /dev/null 2>&1; then
     
        echo
        echo -e "${ARROW} ${YELLOW}Sysbench installing...${NC}"
        curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh 2> /dev/null | sudo bash > /dev/null 2>&1
        sudo apt -y install sysbench > /dev/null 2>&1
	
	 if sysbench --version > /dev/null 2>&1; then
	 
	   string_limit_check_mark "Sysbench $(sysbench --version | awk '{print $2}') installed................................." "Sysbench ${GREEN}$(sysbench --version | awk '{print $2}')${CYAN} installed................................."
	   
	 fi
		
    fi

    install_mongod
    install_nodejs
    install_flux
    sleep 2
}

function install_mongod() {
echo
echo -e "${ARROW} ${YELLOW}Removing any instances of Mongodb...${NC}"
sudo systemctl stop mongod > /dev/null 2>&1 && sleep 1
sudo apt remove mongod* -y > /dev/null 2>&1 && sleep 1
sudo apt purge mongod* -y > /dev/null 2>&1 && sleep 1
sudo apt autoremove -y > /dev/null 2>&1 && sleep 1
echo -e "${ARROW} ${YELLOW}Mongodb installing...${NC}"
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install mongodb-org -y > /dev/null 2>&1 && sleep 2
sudo systemctl enable mongod > /dev/null 2>&1
sudo systemctl start  mongod > /dev/null 2>&1
if mongod --version > /dev/null 2>&1 
then
 #echo -e "${ARROW} ${CYAN}MongoDB version: ${GREEN}$(mongod --version | grep 'db version' | sed 's/db version.//')${CYAN} installed${NC}"
 string_limit_check_mark "MongoDB $(mongod --version | grep 'db version' | sed 's/db version.//') installed................................." "MongoDB ${GREEN}$(mongod --version | grep 'db version' | sed 's/db version.//')${CYAN} installed................................."
 echo
else
 #echo -e "${ARROW} ${CYAN}MongoDB was not installed${NC}" 
 string_limit_x_mark "MongoDB was not installed................................."
 echo
fi
}

function install_nodejs() {
echo -e "${ARROW} ${YELLOW}Removing any instances of Nodejs...${NC}"
n-uninstall -y > /dev/null 2>&1 && sleep 1
rm -rf ~/n
sudo apt-get remove nodejs npm nvm -y > /dev/null 2>&1 && sleep 1
sudo apt-get purge nodejs nvm -y > /dev/null 2>&1 && sleep 1
sudo rm -rf /usr/local/bin/npm
sudo rm -rf /usr/local/share/man/man1/node*
sudo rm -rf /usr/local/lib/dtrace/node.d
sudo rm -rf ~/.npm
sudo rm -rf ~/.nvm
sudo rm -rf ~/.pm2
sudo rm -rf ~/.node-gyp
sudo rm -rf /opt/local/bin/node
sudo rm -rf opt/local/include/node
sudo rm -rf /opt/local/lib/node_modules
sudo rm -rf /usr/local/lib/node*
sudo rm -rf /usr/local/include/node*
sudo rm -rf /usr/local/bin/node*
echo -e "${ARROW} ${YELLOW}Nodejs installing...${NC}"
#export NVM_DIR="$HOME/.nvm" && (
 # git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR" > /dev/null 2>&1 
 # cd "$NVM_DIR"
 # git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)` > /dev/null 2>&1
#) && \. "$NVM_DIR/nvm.sh"
#cd
#curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash > /dev/null 2>&1
curl -SsL -m 10 https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash > /dev/null 2>&1
. ~/.profile
. ~/.bashrc
sleep 1
#nvm install v12.16.1
nvm install v14.18.1 > /dev/null 2>&1
if node -v > /dev/null 2>&1
then
#echo -e "${ARROW} ${CYAN}Nodejs version: ${GREEN}$(node -v)${CYAN} installed${NC}"
string_limit_check_mark "Nodejs $(node -v) installed................................." "Nodejs ${GREEN}$(node -v)${CYAN} installed................................."
echo
else
#echo -e "${ARROW} ${CYAN}Nodejs was not installed${NC}"
string_limit_x_mark "Nodejs was not installed................................."
echo
fi

}

function install_flux() {
   
 docker_check=$(docker container ls -a | egrep 'zelcash|flux' | grep -Eo "^[0-9a-z]{8,}\b" | wc -l)
 resource_check=$(df | egrep 'flux' | awk '{ print $1}' | wc -l)
 mongod_check=$(mongoexport -d localzelapps -c zelappsinformation --jsonArray --pretty --quiet  | jq -r .[].name | head -n1)

if [[ "$mongod_check" != "" && "$mongod_check" != "null" ]]; then

echo -e "${ARROW} ${YELLOW}Detected Flux MongoDB local apps collection ...${NC}" && sleep 1
echo -e "${ARROW} ${CYAN}Cleaning MongoDB Flux local apps collection...${NC}" && sleep 1
echo "db.zelappsinformation.drop()" | mongo localzelapps > /dev/null 2>&1

fi

if [[ $docker_check != 0 ]]; then
echo -e "${ARROW} ${YELLOW}Detected running docker container...${NC}" && sleep 1
echo -e "${ARROW} ${CYAN}Removing containers...${NC}"

sudo service docker restart > /dev/null 2>&1 && sleep 5

docker container ls -a | egrep 'zelcash|flux' | grep -Eo "^[0-9a-z]{8,}\b" |
while read line; do
sudo docker stop $line > /dev/null 2>&1 && sleep 2
sudo docker rm $line > /dev/null 2>&1 && sleep 2
done
fi

if [[ $resource_check != 0 ]]; then
echo -e "${ARROW} ${YELLOW}Detected locked resource${NC}" && sleep 1
echo -e "${ARROW} ${CYAN}Unmounting locked Flux resource${NC}" && sleep 1
df | egrep 'flux' | awk '{ print $1}' |
while read line; do
sudo umount -l $line && sleep 1
done
fi
   
    if [ -d "./$FLUX_DIR" ]; then
         echo -e "${ARROW} ${YELLOW}Removing any instances of Flux${NC}"
         sudo rm -rf $FLUX_DIR
    fi


    echo -e "${ARROW} ${YELLOW}Flux installing...${NC}"
    git clone https://github.com/RunOnFlux/flux.git zelflux > /dev/null 2>&1
    echo -e "${ARROW} ${YELLOW}Creating Flux configuration file...${NC}"
     

if [[ "$KDA_A" != "" ]]; then
  touch ~/$FLUX_DIR/config/userconfig.js
    cat << EOF > ~/$FLUX_DIR/config/userconfig.js
module.exports = {
      initial: {
        ipaddress: '${WANIP}',
        zelid: '${ZELID}',
	kadena: '${KDA_A}',
        testnet: false
      }
    }
EOF
else
    touch ~/$FLUX_DIR/config/userconfig.js
    cat << EOF > ~/$FLUX_DIR/config/userconfig.js
module.exports = {
      initial: {
        ipaddress: '${WANIP}',
        zelid: '${ZELID}',
        testnet: false
      }
    }
EOF
fi

if [ -d ~/$FLUX_DIR ]
then
current_ver=$(jq -r '.version' /home/$USER/$FLUX_DIR/package.json)

string_limit_check_mark "Flux v$current_ver installed................................." "Flux ${GREEN}v$current_ver${CYAN} installed................................."
#echo -e "${ARROW} ${CYAN}Zelflux version: ${GREEN}v$current_ver${CYAN} installed${NC}"

echo
else
string_limit_x_mark "Flux was not installed................................."
#echo -e "${ARROW} ${CYAN}Zelflux was not installed${NC}"
echo
fi

}


function status_loop() {

network_height_01=$(curl -sk -m 10 https://explorer.runonflux.io/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)
network_height_03=$(curl -sk -m 10 https://explorer.zelcash.online/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)

EXPLORER_BLOCK_HIGHT=$(max "$network_height_01" "$network_height_03")


if [[ "$EXPLORER_BLOCK_HIGHT" == $(${COIN_CLI} getinfo | jq '.blocks' 2> /dev/null) ]]; then
echo
echo -e "${CLOCK}${GREEN} FLUX DAEMON SYNCING...${NC}"


LOCAL_BLOCK_HIGHT=$(${COIN_CLI} getinfo 2> /dev/null | jq '.blocks' 2> /dev/null)
CONNECTIONS=$(${COIN_CLI} getinfo 2> /dev/null | jq '.connections' 2> /dev/null)
LEFT=$((EXPLORER_BLOCK_HIGHT-LOCAL_BLOCK_HIGHT))

NUM='2'
MSG1="Syncing progress >> Local block height: ${GREEN}$LOCAL_BLOCK_HIGHT${CYAN} Explorer block height: ${RED}$EXPLORER_BLOCK_HIGHT${CYAN} Left: ${YELLOW}$LEFT${CYAN} blocks, Connections: ${YELLOW}$CONNECTIONS${CYAN}"
MSG2="${CYAN} ................[${CHECK_MARK}${CYAN}]${NC}"
spinning_timer
echo && echo

else
	
   echo
   echo -e "${CLOCK}${GREEN}FLUX DAEMON SYNCING...${NC}"
   
   f=0
   start_sync=`date +%s`

	
    while true
    do
        
        network_height_01=$(curl -sk -m 10 https://explorer.runonflux.io/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)
        network_height_03=$(curl -sk -m 10 https://explorer.zelcash.online/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)

        EXPLORER_BLOCK_HIGHT=$(max "$network_height_01" "$network_height_03")
	
        LOCAL_BLOCK_HIGHT=$(${COIN_CLI} getinfo 2> /dev/null | jq '.blocks' 2> /dev/null)
	CONNECTIONS=$(${COIN_CLI} getinfo 2> /dev/null | jq '.connections' 2> /dev/null)
	LEFT=$((EXPLORER_BLOCK_HIGHT-LOCAL_BLOCK_HIGHT))
	
	if [[ "$LEFT" == "0" ]]; then	
	  time_break='5'
	else
	  time_break='20'
	fi
	
	#if [[ "$CONNECTIONS" == "0" ]]; then
	 # c=$((c+1))
	 # if [[ "$c" > 3 ]]; then
	  # c=0;
	   #LOCAL_BLOCK_HIGHT=""
	#  fi
	
	#fi
	#
	if [[ $LOCAL_BLOCK_HIGHT == "" ]]; then
	
	  f=$((f+1))
	  LOCAL_BLOCK_HIGHT="N/A"
	  LEFT="N/A"
	  CONNECTIONS="N/A"
	  sudo systemctl stop zelcash > /dev/null 2>&1 && sleep 2
	  sudo systemctl start zelcash > /dev/null 2>&1
	
          NUM='60'
          MSG1="Syncing progress => Local block height: ${GREEN}$LOCAL_BLOCK_HIGHT${CYAN} Explorer block height: ${RED}$EXPLORER_BLOCK_HIGHT${CYAN} Left: ${YELLOW}$LEFT${CYAN} blocks, Connections: ${YELLOW}$CONNECTIONS${CYAN} Failed: ${RED}$f${NC}"
          MSG2=''
          spinning_timer
	  
	 network_height_01=$(curl -sk -m 10 https://explorer.runonflux.io/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)
         network_height_03=$(curl -sk -m 10 https://explorer.zelcash.online/api/status?q=getInfo 2> /dev/null | jq '.info.blocks' 2> /dev/null)

          EXPLORER_BLOCK_HIGHT=$(max "$network_height_01" "$network_height_03")
	  
       	  LOCAL_BLOCK_HIGHT=$(${COIN_CLI} getinfo 2> /dev/null | jq '.blocks')
	  CONNECTIONS=$(${COIN_CLI} getinfo 2> /dev/null | jq '.connections')
	  LEFT=$((EXPLORER_BLOCK_HIGHT-LOCAL_BLOCK_HIGHT))

	fi
	
	NUM="$time_break"
        MSG1="Syncing progress >> Local block height: ${GREEN}$LOCAL_BLOCK_HIGHT${CYAN} Explorer block height: ${RED}$EXPLORER_BLOCK_HIGHT${CYAN} Left: ${YELLOW}$LEFT${CYAN} blocks, Connections: ${YELLOW}$CONNECTIONS${CYAN} Failed: ${RED}$f${NC}"
        MSG2=''
        spinning_timer
	
        if [[ "$EXPLORER_BLOCK_HIGHT" == "$LOCAL_BLOCK_HIGHT" ]]; then	
	    echo -e "${GREEN} Duration: $((($(date +%s)-$start_sync)/60)) min. $((($(date +%s)-$start_sync) % 60)) sec. ${CYAN}.............[${CHECK_MARK}${CYAN}]${NC}"
            break
        fi
    done
    
    fi
    
       
   #pm2 start ~/$FLUX_DIR/start.sh --name flux --time > /dev/null 2>&1

    
 # if [[ -z "$mongo_bootstrap" ]]; then
    
   # if   whiptail --yesno "Would you like to restore Mongodb datatable from bootstrap?" 8 60; then
   #      mongodb_bootstrap
   # else
  #      echo -e "${ARROW} ${YELLOW}Restore Mongodb datatable skipped...${NC}"
   # fi
 #   
 # else
   
  #  if [[ "$mongo_bootstrap" == "1" ]]; then
 #     mongodb_bootstrap
  #  else
  #    echo -e "${ARROW} ${YELLOW}Restore Mongodb datatable skipped...${NC}"
   # fi
   
 # fi
    
  #if [[ -z "$watchdog" ]]; then
    #if   whiptail --yesno "Would you like to install watchdog for FluxNode?" 8 60; then
   install_watchdog
   # else
       # echo -e "${ARROW} ${YELLOW}Watchdog installation skipped...${NC}"
   # fi
 #  else
   
    # if [[ "$watchdog" == "1" ]]; then
    #  install_watchdog
    # else
   #   echo -e "${ARROW} ${YELLOW}Watchdog installation skipped...${NC}"
    # fi
   
 #  fi

    check
    display_banner
}

function check() {

cd
pm2 start /home/$USER/$FLUX_DIR/start.sh --restart-delay=30000 --max-restarts=40 --name flux --time  > /dev/null 2>&1
pm2 save > /dev/null 2>&1
#sleep 120
#cd /home/$USER/zelflux
#pm2 stop flux
#npm install --legacy-peer-deps > /dev/null 2>&1
#pm2 start flux 
#cd

NUM='400'
MSG1='Finalizing Flux installation please be patient this will take about ~5min...'
MSG2="${CYAN}.............[${CHECK_MARK}${CYAN}]${NC}"
echo && spinning_timer
echo 

$BENCH_CLI restartnodebenchmarks  > /dev/null 2>&1

NUM='250'
MSG1='Restarting benchmark...'
MSG2="${CYAN}.............[${CHECK_MARK}${CYAN}]${NC}"
spinning_timer
echo && echo
        
echo -e "${BOOK}${YELLOW} Flux benchmarks:${NC}"
echo -e "${YELLOW}======================${NC}"
bench_benchmarks=$($BENCH_CLI getbenchmarks)

if [[ "bench_benchmarks" != "" ]]; then
bench_status=$(jq -r '.status' <<< "$bench_benchmarks")
if [[ "$bench_status" == "failed" ]]; then
echo -e "${ARROW} ${CYAN}Flux benchmark failed...............[${X_MARK}${CYAN}]${NC}"
check_benchmarks "eps" "89.99" " CPU speed" "< 90.00 events per second"
check_benchmarks "ddwrite" "159.99" " Disk write speed" "< 160.00 events per second"
else
echo -e "${BOOK}${CYAN} STATUS: ${GREEN}$bench_status${NC}"
bench_cores=$(jq -r '.cores' <<< "$bench_benchmarks")
echo -e "${BOOK}${CYAN} CORES: ${GREEN}$bench_cores${NC}"
bench_ram=$(jq -r '.ram' <<< "$bench_benchmarks")
bench_ram=$(round "$bench_ram" 2)
echo -e "${BOOK}${CYAN} RAM: ${GREEN}$bench_ram${NC}"
bench_ssd=$(jq -r '.ssd' <<< "$bench_benchmarks")
bench_ssd=$(round "$bench_ssd" 2)
echo -e "${BOOK}${CYAN} SSD: ${GREEN}$bench_ssd${NC}"
bench_hdd=$(jq -r '.hdd' <<< "$bench_benchmarks")
bench_hdd=$(round "$bench_hdd" 2)
echo -e "${BOOK}${CYAN} HDD: ${GREEN}$bench_hdd${NC}"
bench_ddwrite=$(jq -r '.ddwrite' <<< "$bench_benchmarks")
bench_ddwrite=$(round "$bench_ddwrite" 2)
echo -e "${BOOK}${CYAN} DDWRITE: ${GREEN}$bench_ddwrite${NC}"
bench_eps=$(jq -r '.eps' <<< "$bench_benchmarks")
bench_eps=$(round "$bench_eps" 2)
echo -e "${BOOK}${CYAN} EPS: ${GREEN}$bench_eps${NC}"
fi

else
echo -e "${ARROW} ${CYAN}Flux benchmark not responding.................[${X_MARK}${CYAN}]${NC}"
fi
}

function display_banner() {
    echo -e "${BLUE}"
    figlet -t -k "FLUXNODE"
    figlet -t -k "INSTALLATION   COMPLETED"
    echo -e "${YELLOW}================================================================================================================================"
    #echo -e "FLUXNODE INSTALATION COMPLITED${NC}"
    #echo -e "${CYAN}COURTESY OF DK808/XK4MiLX${NC}"
    echo
    if pm2 -v > /dev/null 2>&1; then
	pm2_flux_status=$(pm2 info flux 2> /dev/null | grep 'status' | sed -r 's/│//gi' | sed 's/status.//g' | xargs)
	if [[ "$pm2_flux_status" == "online" ]]; then
	    pm2_flux_uptime=$(pm2 info flux | grep 'uptime' | sed -r 's/│//gi' | sed 's/uptime//g' | xargs)
	    pm2_flux_restarts=$(pm2 info flux | grep 'restarts' | sed -r 's/│//gi' | xargs)
	    echo -e "${BOOK} ${CYAN}Pm2 Flux info => status: ${GREEN}$pm2_flux_status${CYAN}, uptime: ${GREEN}$pm2_flux_uptime${NC} ${SEA}$pm2_flux_restarts${NC}" 
	else
		if [[ "$pm2_flux_status" != "" ]]; then
		    pm2_flux_restarts=$(pm2 info flux | grep 'restarts' | sed -r 's/│//gi' | xargs)
		    echo -e "${PIN} ${CYAN}PM2 Flux status: ${RED}$pm2_flux_status${NC}, restarts: ${RED}$pm2_flux_restarts${NC}" 
		fi
	fi
	    echo
     fi
    echo -e "${ARROW}${YELLOW}  COMMANDS TO MANAGE FLUX DAEMON.${NC}" 
    echo -e "${PIN} ${CYAN}Start Flux daemon: ${SEA}sudo systemctl start zelcash${NC}"
    echo -e "${PIN} ${CYAN}Stop Flux daemon: ${SEA}sudo systemctl stop zelcash${NC}"
    echo -e "${PIN} ${CYAN}Help list: ${SEA}${COIN_CLI} help${NC}"
    echo
    echo -e "${ARROW}${YELLOW}  COMMANDS TO MANAGE BENCHMARK.${NC}" 
    echo -e "${PIN} ${CYAN}Get info: ${SEA}${BENCH_CLI} getinfo${NC}"
    echo -e "${PIN} ${CYAN}Check benchmark: ${SEA}${BENCH_CLI} getbenchmarks${NC}"
    echo -e "${PIN} ${CYAN}Restart benchmark: ${SEA}${BENCH_CLI} restartnodebenchmarks${NC}"
    echo -e "${PIN} ${CYAN}Stop benchmark: ${SEA}${BENCH_CLI} stop${NC}"
    echo -e "${PIN} ${CYAN}Start benchmark: ${SEA}sudo systemctl restart zelcash${NC}"
    echo
    echo -e "${ARROW}${YELLOW}  COMMANDS TO MANAGE FLUX.${NC}"
    echo -e "${PIN} ${CYAN}Summary info: ${SEA}pm2 info flux${NC}"
    echo -e "${PIN} ${CYAN}Logs in real time: ${SEA}pm2 monit${NC}"
    echo -e "${PIN} ${CYAN}Stop Flux: ${SEA}pm2 stop flux${NC}"
    echo -e "${PIN} ${CYAN}Start Flux: ${SEA}pm2 start flux${NC}"
    echo
    if [[ "$WATCHDOG_INSTALL" == "1" ]]; then
    echo -e "${ARROW}${YELLOW}  COMMANDS TO MANAGE WATCHDOG.${NC}"
    echo -e "${PIN} ${CYAN}Stop watchdog: ${SEA}pm2 stop watchdog${NC}"
    echo -e "${PIN} ${CYAN}Start watchdog: ${SEA}pm2 start watchdog --watch${NC}"
    echo -e "${PIN} ${CYAN}Restart watchdog: ${SEA}pm2 reload watchdog --watch${NC}"
    echo -e "${PIN} ${CYAN}Error logs: ${SEA}~/watchdog/watchdog_error.log${NC}"
    echo -e "${PIN} ${CYAN}Logs in real time: ${SEA}pm2 monit${NC}"
    echo
    echo -e "${PIN} ${RED}IMPORTANT: After installation check ${SEA}'pm2 list'${RED} if not work, type ${SEA}'source /home/$USER/.bashrc'${NC}"
    echo
    fi
    echo -e "${PIN} ${CYAN}To access your frontend to Flux enter this in as your url: ${SEA}${WANIP}:${ZELFRONTPORT}${NC}"
    echo -e "${YELLOW}===================================================================================================================[${GREEN}Duration: $((($(date +%s)-$start_install)/60)) min. $((($(date +%s)-$start_install) % 60)) sec.${YELLOW}]${NC}"
    sleep 1
    cd $HOME
    exec bash
}


function start_install() {

start_install=`date +%s`

sudo echo -e "$USER ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo 
echo -e "${CYAN}February 2021, created by dk808 improved by XK4MiLX from Flux's team."
echo -e "Special thanks to Goose-Tech, Skyslayer, & Packetflow."
echo -e "FluxNode setup starting, press [CTRL+C] to cancel.${NC}"
sleep 2

if jq --version > /dev/null 2>&1; then
echo -e ""
else
echo -e ""
echo -e "${ARROW} ${YELLOW}Installing JQ....${NC}"
sudo apt  install jq -y > /dev/null 2>&1

  if jq --version > /dev/null 2>&1
  then
    #echo -e "${ARROW} ${CYAN}Nodejs version: ${GREEN}$(node -v)${CYAN} installed${NC}"
    string_limit_check_mark "JQ $(jq --version) installed................................." "JQ ${GREEN}$(jq --version)${CYAN} installed................................."
    echo
  else
    #echo -e "${ARROW} ${CYAN}Nodejs was not installed${NC}"
    string_limit_x_mark "JQ was not installed................................."
    echo
    exit
  fi
fi

if [ "$USER" = "root" ]; then
    echo -e "${CYAN}You are currently logged in as ${GREEN}root${CYAN}, please switch to the username you just created.${NC}"
    sleep 4
    exit
fi

start_dir=$(pwd)
correct_dir="/home/$USER"
echo -e "${ARROW} ${YELLOW}Checking directory....${NC}"
if [[ "$start_dir" == "$correct_dir" ]]
then
echo -e "${ARROW} ${CYAN}Correct directory ${GREEN}$(pwd)${CYAN} ................[${CHECK_MARK}${CYAN}]${NC}"
else
echo -e "${ARROW} ${CYAN}Bad directory switching...${NC}"
cd
echo -e "${ARROW} ${CYAN}Current directory ${GREEN}$(pwd)${CYAN}${NC}"
fi
sleep 1

config_file

if [[ -z "$index" || -z "$outpoint" || -z "$prvkey" ]]; then
import_date
else

if [[ "$prvkey" != "" && "$outpoint" != "" && "$index" != ""  && "$ZELID" != ""  ]]; then

  IMPORT_ZELCONF="1"
  IMPORT_ZELID="1"
  echo -e ""
  echo -e "${ARROW} ${YELLOW}Install conf settings:${NC}"
  zelnodeprivkey="$prvkey"
  echo -e "${PIN}${CYAN} Identity Key = ${GREEN}$zelnodeprivkey${NC}" && sleep 1
  zelnodeoutpoint="$outpoint"
  echo -e "${PIN}${CYAN} Output TX ID = ${GREEN}$zelnodeoutpoint${NC}" && sleep 1
  zelnodeindex="$index"
  echo -e "${PIN}${CYAN} Output Index = ${GREEN}$zelnodeindex${NC}" && sleep 1

  if [[ "$ZELID" != "" ]]; then
    echo -e "${PIN}${CYAN} Zel ID = ${GREEN}$ZELID${NC}" && sleep 1
  fi
     
  if [[ "$KDA_A" != "" ]]; then
    echo -e "${PIN}${CYAN} KDA address = ${GREEN}$KDA_A${NC}" && sleep 1
  fi

  echo -e ""
  echo -e "${ARROW} ${YELLOW}Watchdog conf settings:${NC}"

  if [[ "$node_label" != "" && "$node_label" != "0" ]]; then
     echo -e "${PIN}${CYAN} Label = ${GREEN}Enabled${NC}" && sleep 1
  else
     echo -e "${PIN}${CYAN} Label = ${RED}Disabled${NC}" && sleep 1
  fi
  
  echo -e "${PIN}${CYAN} Tier_eps_min = ${GREEN}$eps_limit${NC}" && sleep 1   
  
  if [[ "$discord" != "" && "$discord" != "0" ]]; then
     echo -e "${PIN}${CYAN} Discord alert = ${GREEN}Enabled${NC}" && sleep 1
  else
     echo -e "${PIN}${CYAN} Discord alert = ${RED}Disabled${NC}" && sleep 1
  fi

  if [[ "$ping" != "" && "$ping" != "0" ]]; then      
     if [[ "$discord" != "" && "$discord" != "0" ]]; then
       echo -e "${PIN}${CYAN} Discord ping = ${GREEN}Enabled${NC}" && sleep 1
     else
       echo -e "${PIN}${CYAN} Discord ping = ${RED}Disabled${NC}" && sleep 1
     fi
  fi
	      
  if [[ "$telegram_alert" != "" && "$telegram_alert" != "0" ]]; then
    echo -e "${PIN}${CYAN} Telegram alert = ${GREEN}Enabled${NC}" && sleep 1
  else
    echo -e "${PIN}${CYAN} Telegram alert = ${RED}Disabled${NC}" && sleep 1
  fi
	      
  if [[ "$telegram_alert" == "1" ]]; then
    echo -e "${PIN}${CYAN} Telegram bot token = ${GREEN}$telegram_alert${NC}" && sleep 1	
  fi
	      
  if [[ "$telegram_alert" == "1" ]]; then
     echo -e "${PIN}${CYAN} Telegram chat id = ${GREEN}$telegram_chat_id${NC}" && sleep 1	
  fi
  echo -e ""
  
fi

fi

}

#end of functions
    start_install
    wipe_clean
    ssh_port
    ip_confirm
    create_swap
    install_packages
    create_conf
    install_daemon
    zk_params
    if [[ "$BOOTSTRAP_SKIP" == "0" ]]; then
    bootstrap
    fi
    create_service_scripts
    create_service
    
   # if whiptail --yesno "Is the fluxnode being installed on a vps?" 8 60; then   
   #   echo -e "${ARROW} ${YELLOW}Cron service for rotate ip skipped...${NC}"
  #  else
      # if whiptail --yesno "Would you like to install cron service for rotate ip (required for dynamic ip)?" 8 60; then
         selfhosting
      ## else
         #echo -e "${ARROW} ${YELLOW}Cron service for rotate ip skipped...${NC}"
      ### fi 
  ##  fi
    
    install_process
    start_daemon
    log_rotate "Flux benchmark" "bench_debug_log" "/home/$USER/$BENCH_DIR_LOG/debug.log" "monthly" "2"
    log_rotate "Flux daemon" "daemon_debug_log" "/home/$USER/$CONFIG_DIR/debug.log" "daily" "7"
    log_rotate "MongoDB" "mongod_debug_log" "/var/log/mongodb/*.log" "daily" "14"
    log_rotate "Docker" "docker_debug_log" "/var/lib/docker/containers/*/*.log" "daily" "7"
    basic_security
    status_loop
