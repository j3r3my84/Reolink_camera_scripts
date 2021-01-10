#!/bin/bash
####################################################
# Reolink camera still image downloader
####################################################

log_name="capture.log"
save_path="./"
file_name="$(date +%Y-%m-%d_%H-%M-%S).jpg"
ip=""
port="80"
user="admin"
password=""
wait_time="0"

check_path()
{
	if [ ! -d "$save_path" ]; then
		echo "Selected path does not exist. Try -h for usage."
		exit
	fi
}

check_ip()
{
	if [[ -z $ip ]]; then
		echo "The camera ip address must be set. Try -h for usage."
	else
		if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
			echo "Invalid ip address. Try -h for usage."
			exit
		fi
	fi
}

check_port()
{
	if [[ ! $port =~ ^[0-9]+$ ]]; then
		echo "Invalid port. Try -h for usage."
		exit
	fi
}

check_wait_time()
{
	if [[ ! $wait_time =~ ^[0-9]+$ ]]; then
		echo "Invalid wait interval. Try -h for usage."
		exit
	fi
}

usage()
{
	echo "Capture still images from the Reolink IP surveillance camera as .jpg file"
	echo
	echo "Usage: capture.sh [option]..."
	echo "List of options:"
	echo "  -o    output file name (default: Y-m-d_H-M-S.jpg)"
	echo "  -d    output file path (default: current dir)"
	echo "  -a    camera ip address"
	echo "  -P    camera port (default: 80)"
	echo "  -u    username for camera login (default: admin)"
	echo "  -p    password for camera login (default: empty)"
	echo "  -i    interval between images in seconds (continously run). If is set, the file name option will be ignored and the default file name will be used"
	echo "  -h    display this help and exit"	
}

while getopts "o:d:a:p:u:P:i:h" opt; do
  case $opt in
    o) file_name="${OPTARG}";;
    d) save_path="${OPTARG}";;
	a) ip="${OPTARG}";;
	P) port="${OPTARG}";;
	u) user="${OPTARG}";;
	p) password="${OPTARG}";;
	i) wait_time="${OPTARG}";;
	h) usage
	   exit;;
    \?) echo "Invalid option -$OPTARG" >&2
	    echo ""
		usage;;
  esac
done
check_path
check_ip
check_port
if [ $wait_time -gt 0 ]; then 
	file_name="$(date +%Y-%m-%d_%H-%M-%S).jpg"
	count=1
	wget -nv -t 1 -o "$save_path/$log_name" -O "$save_path/$file_name" "http://$ip:$port/cgi-bin/api.cgi?cmd=Snap&channel=0&user=$user&password=$password"
	if [ $? -ne 0 ]; then
		echo "There was an error. See $log_name for more details."
		exit 1
	fi
	echo "This script will run indefinitely. Press Ctrl+c to stop..."
	echo "See $log_name for details."
	echo -ne "\rCaptured images: $count"
	while true; do
		sleep $wait_time
		file_name="$(date +%Y-%m-%d_%H-%M-%S).jpg"
		wget -nv -b -t 1 -a "$save_path/$log_name" -O "$save_path/$file_name" "http://$ip:$port/cgi-bin/api.cgi?cmd=Snap&channel=0&user=$user&password=$password" > /dev/null 2>&1 &
		((count=count+1))
		echo -ne "\rCaptured images: $count"
	done
	exit
else
	wget -q -t 1 -O "$save_path/$file_name" "http://$ip:$port/cgi-bin/api.cgi?cmd=Snap&channel=0&user=$user&password=$password" 2>&1 | grep -i "failed\|error"
	exit
fi