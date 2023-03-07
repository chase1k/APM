#!/bin/bash

# Global Variables
pid1=0
pid2=0
pid3=0
pid4=0
pid5=0
pid6=0
timer=0



spawn() { 
    # Start Processes @ Save PIDs
    ./project1_executables/APM1 $1 &
    pid1=$!
    ./project1_executables/APM2 $1 &
    pid2=$!
    ./project1_executables/APM3 $1 &
    pid3=$!
    ./project1_executables/APM4 $1 &
    pid4=$!
    ./project1_executables/APM5 $1 &
    pid5=$! 
    ./project1_executables/APM6 $1 &
    pid6=$!

    # Set Update Rate & Create Files
    ifstat -d 1
    echo "seconds,RX,TX" > metrics/system_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM1_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM2_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM3_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM4_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM5_metrics.csv
    echo "seconds,cpu(%),memory(%)" > metrics/APM6_metrics.csv
}

# Person 2
proc_level_metrics() {
    # Use ps to get process metrics
    # use the pid variable to display only the PID we want
    # use cut or awk to get the usage stats
    # CPU - In % Util
    # Memory - In % Util
    ps=$(ps -eo pid,%cpu,%mem | tr -s ' ')

    # PID 1
    output=$(echo $ps | grep $pid1 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    #echo $(echo $ps | grep $pid1)
    echo "$timer,$output" >> metrics/APM1_metrics.csv 
    # PID 2
    output=$(echo $ps | grep $pid2 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM2_metrics.csv 
    # PID 3
    output=$(echo $ps | grep $pid3 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM3_metrics.csv 
    # PID 4
    output=$(echo $ps | grep $pid4 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM4_metrics.csv 
    # PID 5
    output=$(echo $ps | grep $pid5 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM5_metrics.csv 
    # PID 6
    output=$(echo $ps | grep $pid6 | cut -d ' ' -f4,5 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM6_metrics.csv 
}

# Person 2
sys_level_metrics() {
    # ifstat to get network usage - Upload/Download Speed (KB/s)
    RX=$(ifstat | grep "ens33" | tr -s ' ' | cut -d ' ' -f6 | sed 's/K//g')
    TX=$(ifstat | grep "ens33" | tr -s ' ' | cut -d ' ' -f8 | sed 's/K//g')
    # iostat to get hdd usage - Read/Write (KB/s)
    read=$(iostat sda | grep "sda" |  tr -s ' ' | cut -d ' ' -f3)
    write=$(iostat sda | grep "sda" |  tr -s ' ' | cut -d ' ' -f4)
    # df to get HDD space left - Display in (MB)
    echo "$timer, $RX, $TX,  $read, $write" >> metrics/system_metrics.csv
}

# Person 1
cleanup() {
    # Get all PIDS with APM* processes
    # Kill APM processes by PID
    kill $pid1
    kill $pid2 
    kill $pid3
    kill $pid4
    kill $pid5
    kill $pid6
    
    # Kill ifstat by name 
    pkill ifstat
    # Generate Reports?
} 
trap cleanup EXIT


#Report Person 1 and 2

##########
## Main ##
##########

# IP Provided
if [ $# != 1 ] 
then
    echo "Usage ./Project1.sh <IP_Address>"
    exit -1
fi

# Start Processes
spawn $1

# Enter Loop
while true; do
    sleep 5
    timer=$(($SECONDS))
    proc_level_metrics
    sys_level_metrics
    echo "Timer: $timer"
done

