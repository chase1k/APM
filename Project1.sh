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
    # IP Provided
    if [ $# -ne $1 ] 
    then
        echo "Usage <Ip>"
        exit 1
    fi

    # Start Processes @ Save PIDs
    ./APM1 $1 &
    pid1=$!
    ./APM2 $1 &
    pid2=$!
    ./APM3 $1 &
    pid3=$!
    ./APM4 $1 &
    pid4=$!
    ./APM5 $1 &
    pid5=$! 
    ./APM6 $1 &
    pid6=$!

    # Set Update Rate & Create Files
    ifstat -d 1
    echo "" > metrics/system_metrics.csv
    echo "" > metrics/APM1_metrics.csv
    echo "" > metrics/APM2_metrics.csv
    echo "" > metrics/APM3_metrics.csv
    echo "" > metrics/APM4_metrics.csv
    echo "" > metrics/APM5_metrics.csv
    echo "" > metrics/APM6_metrics.csv
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
    output=$(echo $ps | grep $pid1 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM1_metrics.csv 
    # PID 2
    output=$(echo $ps | grep $pid2 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM2_metrics.csv 
    # PID 3
    output=$(echo $ps | grep $pid3 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM3_metrics.csv 
    # PID 4
    output=$(echo $ps | grep $pid4 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM4_metrics.csv 
    # PID 5
    output=$(echo $ps | grep $pid5 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM5_metrics.csv 
    # PID 6
    output=$(echo $ps | grep $pid6 | cut -d -f2,3 | sed 's/ /,/g')
    echo "$timer,$output" >> metrics/APM6_metrics.csv 
}

# Person 2
sys_level_metrics() {
    # ifstat to get network usage - Upload/Download Speed (KB/s)
    # iostat to get hdd usage - Read/Write (KB/s)
    # df to get HDD space left - Display in (MB)
	echo "Sys level metrics"
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

# Start Processes
spawn

# Enter Loop
while true; do
    sleep 5
    timer=$(($timer+5))
    proc_level_metrics
    sys_level_metrics
done

