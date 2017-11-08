#!/bin/bash
#
# Use this script to test backup configurations...
#
# export setTo="30 DEC 2016 21:59:00" # Backups up to a weekly...
# export setTo="2 JAN 2017 21:59:00"  # Backup to a daily 1
# export setTo="3 JAN 2017 21:59:00"  # Backup to a daily 1
# export setTo="4 JAN 2017 21:59:00"  # Backup to a daily 1
# export setTo="5 JAN 2017 21:59:00"  # Backup to a daily 1
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
echo "Updating date and time on webserver, and restarting fd"
vagrant ssh -c "date && sudo date -s \"$setTo\" && date && sudo systemctl restart bareos-fd" webserver
echo "-------------------"
echo "Making some random changes to the webserver so there's something to backup."
vagrant ssh -c "/home/vagrant/random.sh" webserver
echo "-------------------"
echo "Updating date and time on bareos-dir, and restarting director...then monitoring job..."
vagrant ssh -c "date && sudo date -s \"$setTo\" && date && echo \"disable schedule=WeeklyCycle\" | bconsole  && sudo systemctl restart bareos-dir && watch -n1 \"echo 'status client=webserver-fd' | bconsole\"" bareOSdirector


