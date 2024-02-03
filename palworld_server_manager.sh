#!/bin/bash

# Function to display the current time in KST
echo_ct_kst() {
    echo "TIME: $(TZ='Asia/Seoul' date +'%y-%m-%d-%H-%M-%S')"
}

# Function to stop the palworld-server Docker container
stop_palworld() {
    echo "Stopping palworld-server..."
    echo_ct_kst
    sleep 10	
    sudo docker exec -i palworld-server rcon-cli "broadcast This_server_shuts_down_after_60_seconds."
    sleep 30	
    sudo docker exec -i palworld-server rcon-cli save
    sudo docker exec -i palworld-server rcon-cli shutdown
    echo "palworld-server will shut down in 30 seconds."
    sleep 31
    sudo docker stop palworld-server
    echo "palworld-server stopped!!"
    echo_ct_kst
}

# Function to start the palworld-server Docker container
start_palworld() {
    echo "Starting palworld-server..."
    echo_ct_kst
    sudo docker start palworld-server
    echo "palworld-server started!!"
    echo_ct_kst
	sleep 60
    sudo docker exec -i palworld-server rcon-cli "broadcast Hello,_Pal_Master.The_server_uptime_is_1_minute."
	sleep 60
    sudo docker exec -i palworld-server rcon-cli "broadcast Hi,_Pal_Master.The_server_uptime_is_2_minute."
	sleep 60
    sudo docker exec -i palworld-server rcon-cli "broadcast Welcome,_Pal_Master.The_server_uptime_is_3_minute."
    sudo docker exec -i palworld-server rcon-cli save
}

# Function to backup and compress the /home/serverfile/palworld/Pal/Saved/ directory
backup_palworld() {
    echo_ct_kst
    echo "Backup and Compressing palworld-server files..."
    TIMESTAMP=$(TZ='Asia/Seoul' date +'%y-%m-%d-%H-%M-%S')
    BACKUP_PATH="/home/serverfile/backups/${TIMESTAMP}-palworld-backup.tar.gz"
    tar -czf "${BACKUP_PATH}" -C /home/serverfile/palworld/Pal/Saved/ .
    echo "Backup and Compression completed!!"
	sleep 1
    sudo docker exec -i palworld-server rcon-cli "broadcast A_backup_of_the_server_at_the_current_time_has_been_created."
    echo_ct_kst
}

# Function to check memory usage and perform actions if it exceeds 80%
check_palworld() {
    echo "Checking memory usage..."
    echo_ct_kst
    # Get total and used memory in megabytes
    read total used <<< $(free -m | awk '/Mem:/ {print $2 " " $3}')
	echo "Current memory usage: $(awk '/MemTotal/{total=$2}/MemAvailable/{available=$2} END {printf "%.2f", (total-available)/total*100}' /proc/meminfo)%" 

    # Calculate used memory as percentage of total
    used_pct=$((used * 100 / total))

    if [ "$used_pct" -gt 80 ]; then
        echo "Memory usage above 80%. Executing save and shutdown commands..."
        sudo docker exec -i palworld-server rcon-cli "broadcast The_memory_usage_of_the_server_is_too_high."
		sleep 1
        sudo docker exec -i palworld-server rcon-cli "broadcast The_server_will_be_restarted_in_60_seconds."
		sleep 1
        sudo docker exec -i palworld-server rcon-cli "broadcast Stop_everything_you_are_doing_and_disconnect_from_the_server."
		sleep 1
        sudo docker exec -i palworld-server rcon-cli save
		sleep 3
        sudo docker exec -i palworld-server rcon-cli "broadcast See_you_later!"
        sudo docker exec -i palworld-server rcon-cli shutdown 120
        echo "Shutdown initiated. Server will restart after a designated delay."
        sleep 61 # Wait for 60 seconds after save before initiating shutdown
        echo "Restarting palworld-server..."
        sleep 30 # Delay before restarting the server, adjust this value as needed
        sudo docker start palworld-server
        echo "palworld-server restarted."
    else
        echo "Memory usage below 80%."
		echo "Current memory usage: $(awk '/MemTotal/{total=$2}/MemAvailable/{available=$2} END {printf "%.2f", (total-available)/total*100}' /proc/meminfo)%" 
		sleep 5
        sudo docker exec -i palworld-server rcon-cli "broadcast The_server_checker_is_complete."
		sleep 1
        sudo docker exec -i palworld-server rcon-cli "broadcast The_server_is_stable_now."
		sleep 1
        sudo docker exec -i palworld-server rcon-cli "broadcast Have_a_nice_day,_Pal_masters!!"
		echo_ct_kst
    fi
    echo_ct_kst
}


# Main logic to call functions based on passed argument
case "$1" in
    stop)
        stop_palworld
        ;;
    start)
        start_palworld
        ;;
    backup)
        backup_palworld
        ;;
    check)
        check_palworld
        ;;
    *)
        echo "Usage: $0 {start|stop|backu|check}"
        exit 1
        ;;
esac

