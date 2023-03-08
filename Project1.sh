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

    echo "PID Values of each APM executable: $pid1 $pid2 $pid3 $pid4 $pid5 $pid6"

    # Set Update Rate & Create Files
    ifstat -d 1
    echo "seconds,RX,TX,read(kB/s),write(kB/s),usage of /(MB)" > metrics/system_metrics.csv
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
    # use cut to get the usage stats
    # CPU - In % Util
    # Memory - In % Util

    # PID 1 never has any usage
    output=$(ps -q $pid1 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
    echo "$timer,$output" >> metrics/APM1_metrics.csv 
    # PID 2 never has any usage
    output=$(ps -q $pid2 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
    echo "$timer,$output" >> metrics/APM2_metrics.csv 
    # PID 3
    output=$(ps -q $pid3 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
    echo "$timer,$output" >> metrics/APM3_metrics.csv 
    # PID 4
    output=$(ps -q $pid4 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
    echo "$timer,$output" >> metrics/APM4_metrics.csv 
    # PID 5
    output=$(ps -q $pid5 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
    echo "$timer,$output" >> metrics/APM5_metrics.csv 
    # PID 6
    output=$(ps -q $pid6 -o pcpu,pmem | tail -n1 | tr -s ' ' ',' | cut -c 2- )
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
    stor=$(df -m / | grep "/" | tr -s ' ' | cut -d ' ' -f3)
    echo "$timer, $RX, $TX, $read, $write, $stor" >> metrics/system_metrics.csv
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
    echo "Timer: $timer seconds elapsed"
done

