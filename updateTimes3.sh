#!/bin/bash
#
# Use this script to test backup configurations...
#
source ../log4bash/log4bash.sh

# Set the default start date
startDate="30 DEC 2016 21:59:45"

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

justStartDate=$(date --date="$startDate" +"%d %b %Y")
justStartTime=$(date --date="$startDate" +"%R:%S")

justCopyJobBackupTime="11:59:45"

#startDate="02 JAN 2017 21:59:55"
dasDates=()
dasCopyJobDates=()

for i in $(seq 0 $1)
  do
   
   # Set each of the Job Dates in an array.
   nextDate=$(date --date="$justStartDate $justStartTime $i days" +"%d %b %Y %R:%S" )
   dasDates+=("$nextDate")

   j=$(($i+1))

   # Set each of the Copy Job Dates in an array.
   nextCopyJobDate=$(date --date="$justStartDate $justCopyJobBackupTime $j days" +"%d %b %Y %R:%S" )
   log_error "$nextCopyJobDate"
   dasCopyJobDates+=("$nextCopyJobDate")
  done

for ((i=0;i<${#dasDates[@]};++i)); do
   log "-------------------------"
   log "Job ${i}: ${dasDates[$i]}"
   log "CopyJob ${i}: ${dasCopyJobDates[$i]}"
done

#for setTo in "${dasDates[@]}"
#  do
#   log "$setTo"
#  done
#
#
for ((i=0;i<${#dasDates[@]};++i)); do
#   #echo $setTo
   #vagrant snapshot save bareOSdirector ${i}
   #vagrant snapshot save bareOSremoteSD ${i}
   
   log_info "Processsing Backup Job for: ${dasDates[$i]}, and Backup Copy Job for: ${dasCopyJobDates[$i]}"
   log_info "--------------------------------------------------------------------------------"
   log_warning "1.1 Updating date and time on webserver to ${dasDates[$i]}, and restarting fd"
   vagrant ssh -c "date && sudo date -s \"${dasDates[$i]}\" && date" webserver
   log_warning ""
   log_warning "1.2 Making some random changes to the webserver, so there's something to backup..."
   vagrant ssh -c "date >> /home/vagrant/dates.txt" webserver
   #vagrant ssh -c "/home/vagrant/random.sh" webserver
   log_warning "" 
   log_warning "1.3 Updating date and time on bareos-dir to ${dasDates[$i]}, and restarting director...then monitoring job..."
   vagrant ssh -c "date && sudo date -s \"${dasDates[$i]}\" && date && sudo systemctl restart bareos-dir && sudo systemctl restart bareos-sd && echo \"disable schedule=WeeklyCycle\" | bconsole" bareOSdirector
   log_warning "1.4 Waiting 15 seconds for backup to occur."
   sleep 30s # Wait 15 seconds for the backup to occur.

   log_warning "2.1 Updating date and time on bareos-remote-fd to ${dasCopyJobDates[$i]}, and restarting file daemon..."
   vagrant ssh -c "date && sudo date -s \"${dasCopyJobDates[$i]}\" && sudo systemctl restart bareos-sd" bareOSremoteSD
   log_warning "2.2 Updating date and time on bareos-dir to ${dasCopyJobDates[$i]}, and restarting director..."
   vagrant ssh -c "date && sudo date -s \"${dasCopyJobDates[$i]}\" && date && sudo systemctl restart bareos-dir && sudo systemctl restart bareos-sd && echo \"disable schedule=WeeklyCycle\" | bconsole" bareOSdirector
   log_warning "2.3 Waiting 15 seconds for the copy job to occur."
   sleep 30s
   log_info "--------------------------------------------------------------------------------"


   # Output a human readable set of jobs.
   vagrant ssh -c "date" bareOSdirector >> ./testlog/webserver-job-humanReadable.txt
   vagrant ssh -c "mysql -uroot -Dbareos --execute \"SELECT Job.JobId AS JobID, Job.Name AS JobName, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime) AS WeekNum, Media.VolStatus, IF(STRCMP(Media.VolStatus, 'Used'), 'NA',DATE_ADD(Media.LastWritten, INTERVAL Media.VolRetention second)) AS VolRecycleTime, DAYNAME(Job.StartTime) AS DayOfWeek, Job.StartTime AS StartTime, JobFiles AS Files,ROUND(JobBytes/1024.0/1024.0/1024.0,3) AS GB FROM Job,JobMedia,Media WHERE JobMedia.JobId=Job.JobId AND JobMedia.MediaId=Media.MediaId AND Name='webserver-job' AND VolumeName NOT LIKE '%CopyPool%' GROUP by Job.JobID, Job.Name, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime), DAYNAME(Job.StartTime), Job.StartTime, JobBytes, JobFiles, Media.VolStatus, DATE_ADD(LastWritten, INTERVAL VolRetention second) ORDER by JobId, JobName, StartTime;\"" bareOSdirector >> ./testlog/webserver-job-humanReadable.txt
   vagrant ssh -c "echo \"---------------------------------\"" bareOSdirector >> ./testlog/webserver-job-humanReadable.txt
	
   # Output a csv readable set of jobs.
   vagrant ssh -c "mysql -uroot -Dbareos --batch --raw --execute \"SELECT Job.JobId AS JobID, Job.Name AS JobName, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime) AS WeekNum, Media.VolStatus, IF(STRCMP(Media.VolStatus, 'Used'), 'NA',DATE_ADD(Media.LastWritten, INTERVAL Media.VolRetention second)) AS VolRecycleTime, DAYNAME(Job.StartTime) AS DayOfWeek, Job.StartTime AS StartTime, JobFiles AS Files,ROUND(JobBytes/1024.0/1024.0/1024.0,3) AS GB FROM Job,JobMedia,Media WHERE JobMedia.JobId=Job.JobId AND JobMedia.MediaId=Media.MediaId AND Job.Name='webserver-job' AND VolumeName NOT LIKE '%CopyPool%' GROUP by Job.JobID, Job.Name, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime), DAYNAME(Job.StartTime), Job.StartTime, JobBytes, JobFiles, Media.VolStatus, DATE_ADD(LastWritten, INTERVAL VolRetention second) ORDER by JobId, JobName, StartTime;\"" bareOSdirector | sed 's/\t/,/g' > ./testlog/webserver-job-csv/${i}.csv


   # Output a human readable set of copy jobs.
   vagrant ssh -c "date" bareOSdirector >> ./testlog/webserver-copy-job-humanReadable.txt
   vagrant ssh -c "mysql -uroot -Dbareos --execute \"SELECT Job.JobId AS JobID, Job.Name AS JobName, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime) AS WeekNum, Media.VolStatus, IF(STRCMP(Media.VolStatus, 'Used'), 'NA',DATE_ADD(Media.LastWritten, INTERVAL Media.VolRetention second)) AS VolRecycleTime, DAYNAME(Job.StartTime) AS DayOfWeek, Job.StartTime AS StartTime, JobFiles AS Files,ROUND(JobBytes/1024.0/1024.0/1024.0,3) AS GB FROM Job,JobMedia,Media WHERE JobMedia.JobId=Job.JobId AND JobMedia.MediaId=Media.MediaId AND Name='webserver-job' AND VolumeName LIKE '%CopyPool%' GROUP by Job.JobID, Job.Name, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime), DAYNAME(Job.StartTime), Job.StartTime, JobBytes, JobFiles, Media.VolStatus, DATE_ADD(LastWritten, INTERVAL VolRetention second) ORDER by JobId, JobName, StartTime;\"" bareOSdirector >> ./testlog/webserver-copy-job-humanReadable.txt
   vagrant ssh -c "echo \"---------------------------------\"" bareOSdirector >> ./testlog/webserver-copy-job-humanReadable.txt

   # Output a csv readable set of copy jobs.
   vagrant ssh -c "mysql -uroot -Dbareos --batch --raw --execute \"SELECT Job.JobId AS JobID, Job.Name AS JobName, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime) AS WeekNum, Media.VolStatus, IF(STRCMP(Media.VolStatus, 'Used'), 'NA',DATE_ADD(Media.LastWritten, INTERVAL Media.VolRetention second)) AS VolRecycleTime, DAYNAME(Job.StartTime) AS DayOfWeek, Job.StartTime AS StartTime, JobFiles AS Files,ROUND(JobBytes/1024.0/1024.0/1024.0,3) AS GB FROM Job,JobMedia,Media WHERE JobMedia.JobId=Job.JobId AND JobMedia.MediaId=Media.MediaId AND Job.Name='webserver-job' AND VolumeName LIKE '%CopyPool%' GROUP by Job.JobID, Job.Name, VolumeName, Job.Level, Job.JobStatus, WEEK(Job.StartTime), DAYNAME(Job.StartTime), Job.StartTime, JobBytes, JobFiles, Media.VolStatus, DATE_ADD(LastWritten, INTERVAL VolRetention second) ORDER by JobId, JobName, StartTime;\"" bareOSdirector | sed 's/\t/,/g' > ./testlog/webserver-copy-job-csv/${i}.csv

done

# export setTo="30 DEC 2016 21:59:55" # Backups up to a weekly...

# export setTo="31 DEC 2016 11:59:55" # Copy Job to Remote SD.

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


