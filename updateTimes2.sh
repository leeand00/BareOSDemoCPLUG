#!/bin/bash
#
# Use this script to test backup configurations...
#


# Set the default start date
startDate="30 DEC 2016 21:59:55"

# Print usage
if [ $# -eq 0 ]; 
 then
  echo ""
  echo "Usage: updateTimes2.sh <num-days> [<start-date>]"
  echo ""
  echo ""
  echo "Example 1:"
  echo ""
  echo ""
  echo "Example 2:"
  echo ""
  echo "  updateTimes.sh 0 \"14 JAN 2017 21:59:55\""
  echo ""
  echo "  Note: This will do the backup for the specified day and exit."
  echo ""
  echo "Example 3:"
  echo ""  
  echo "  updateTimes.sh 14"
  echo ""
  echo "  Note: This defaults to \"30 DEC 2016 21:59:55\" as the start time."
  echo ""
  echo "Example 4:"
  echo ""
  echo "  updateTimes.sh 14 \"14 JAN 2017 21:59:55\""
  exit
fi


if [ -z "${2:0}" ]; 
 then
  startDate=$startDate
 else
  startDate=$2
fi


#startDate="02 JAN 2017 21:59:55"
dasDates=()

for i in $(seq 0 $1)
  do
   nextDate=$(date --date="$startDate $i days" +"%d %b %Y %R:%S" )	  
   dasDates=("${dasDates[@]}" "$nextDate")
  done

for setTo in "${dasDates[@]}" 
  do
   #echo $setTo
   echo "Updating date and time on webserver, and restarting fd"
   vagrant ssh -c "date && sudo date -s \"$setTo\" && date && sudo systemctl restart bareos-fd" webserver
   echo "------------------- "
   echo "Making some random changes to the webserver, so there's something to backup..."
   vagrant ssh -c "/home/vagrant/random.sh" webserver
   echo "-------------------"
   echo "Updating date and time on bareos-dir, and restarting director...then monitoring job..."
   vagrant ssh -c "date && sudo date -s \"$setTo\" && date && echo \"disable schedule=WeeklyCycle\" | bconsole  && sudo systemctl restart bareos-dir" bareOSdirector
   sleep 15s # Wait 10 seconds for the backup to occur.
 done

# export setTo="30 DEC 2016 21:59:55" # Backups up to a weekly...
# export setTo="2 JAN 2017 21:59:55"  # Backup to a daily 1
# export setTo="3 JAN 2017 21:59:55"  # Backup to a daily 1
# export setTo="4 JAN 2017 21:59:55"  # Backup to a daily 1
# export setTo="5 JAN 2017 21:59:55"  # Backup to a daily 1
# export setTo="6 JAN 2017 21:59:00"  # Backup to a monthly 1
# export setTo="9 JAN 2017 21:59:00"  # Backup to a daily 2
# export setTo="10 JAN 2017 21:59:00" # Backup to a daily 2
# export setTo="11 JAN 2017 21:59:00" # Backup to a daily 2
# export setTo="12 JAN 2017 21:59:00" # Backup to a daily 2
# export setTo="13 JAN 2017 21:59:00" # Backup to a weekly 2
# export setTo="16 JAN 2017 21:59:00" # Recycle daily 1 backup to a daily 1
# export setTo="17 JAN 2017 21:59:00" # backup to a daily 1
# export setTo="18 JAN 2017 21:59:00" # backup to a daily 1
# export setTo="19 JAN 2017 21:59:00" # backup to a daily 1
# export setTo="20 JAN 2017 21:59:00" # backup to a weekly 3 
# export setTo="23 JAN 2017 21:59:00" # backup to a daily 2
# export setTo="24 JAN 2017 21:59:00"  #backup to a daily 2
# export setTo="25 JAN 2017 21:59:00" # backup to a daily 2
# export setTo="26 JAN 2017 21:59:00" # backup to a daily 2
# export setTo="27 JAN 2017 21:59:00" # backup to a weekly 4
# export setTo="30 JAN 2017 21:59:00" # backup to a daily 1
# export setTo="31 JAN 2017 21:59:00" # backup to a daily 1

# export setTo="01 FEB 2017 21:59:00" # backup to a daily 1
# export setTo="02 FEB 2017 21:59:00" # backup to a daily 1
# export setTo="03 FEB 2017 21:59:00" # backup to a monthly 2

#B4 running this, set the following env var:
#export setTo="06 JAN 2017 21:59:00"
#echo "Updating date and time on webserver, and restarting fd"
#vagrant ssh -c "date && sudo date -s \"$setTo\" && date && sudo systemctl restart bareos-fd" webserver
#echo "-------------------"
#echo "Updating date and time on bareos-dir, and restarting director...then monitoring job..."
#vagrant ssh -c "date && sudo date -s \"$setTo\" && date && echo \"disable schedule=WeeklyCycle\" | bconsole  && sudo systemctl restart bareos-dir && watch -n1 \"echo 'status client=webserver-fd' | bconsole\"" bareOSdirector


