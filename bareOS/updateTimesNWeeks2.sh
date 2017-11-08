#!/bin/bash

# SYNOPSIS:
# This script will iterate between Mondays and Fridays, so that the effects of 
# the recycling in BareOS can be shown in its output.
#
# DEPENDENCIES:
# - ./updateTimes3.sh
#
# INPUT:
# Specify one argument to specify the number of weeks to iterate though, see gfs19_gfs21.ods.
# 
# PROCESS:
#
# The script calls ./updateTimes3.sh and that script takes two arguments:
#  - arg1: How many days to iterate (specifying 0 implies to iterate over only the date specified in arg2).
#  - arg2: The date and time to set the BareOS Director VMs time to (so that it will run a scheduled backup)
#
# Note that you can also call ./updateTimes3.sh to gain finer control over testing the backups.
#
# OUTPUT:
# It outputs to the project sub-directory ./testLog where a human readable and 
# csv files version are available with the results of each iteration.
#

#
# Andrew J. Leer - 09/23/2017


# defaultLastBackup specifies the first day of the year a Sunday in 2017.
# note that you may need to change this date depending on the year in question, 
# but that it will most likely start on a Sunday since Monday begins the daily 
# span of four (4)  "daily pool" backups (at least for gfs19 and gfs21).
defaultLastBackup="01 JAN 2017"

for i in $(seq 0 $1)
  do
    vagrant snapshot save bareOSdirector ${i}
    vagrant snapshot save bareOSremoteSD ${i}

    # Get the possible date of the last backup
    lastBackup=$(vagrant ssh -c "echo \"list jobs client=webserver-fd job=webserver-job \" | bconsole" bareOSdirector | grep "^|" | sed -e 's/|//g' -e 's/,//g' -e 's/^ +//' -e 's/^\s\+//g' -e 's/\s\+$//g' -e 's/\s\+/,/g' -e 's/StartTime,/StartDate,\0/g' | tail -n1 | grep -o -e '[0-9]\{4\}-[0-9]\{1,\}-[0-9]\{1,\}')
    lastBackupTime=$(vagrant ssh -c "echo \"list jobs client=webserver-fd job=webserver-job \" | bconsole" bareOSdirector | grep "^|" | sed -e 's/|//g' -e 's/,//g' -e 's/^ +//' -e 's/^\s\+//g' -e 's/\s\+$//g' -e 's/\s\+/,/g' -e 's/StartTime,/StartDate,\0/g' | tail -n1 | cut -f5 -d,)
    
    echo "${lastBackup} ${lastBackupTime}"

    # check if there was a last backup
    if [[ ! -z "${lastBackup// }" ]]
     then
       echo "Not my first time at the rodeo!"
     else 
       # If it's the firstBackup 
       echo "First time at the rodeo!"
       lastBackup="${defaultLastBackup}"
     fi


       dowLastBackup=$(date -d "${lastBackup}" +%a)
      
       echo "dowLastBackup: ${dowLastBackup}"
       declare -A whichArg=()

       if [ ${dowLastBackup} == "Fri" ];
        then
	   # cusp of weekend to monday
	   whichArg[argOne]="0" 
	   whichArg[addDate]="3"
       elif [ ${dowLastBackup} == "Mon" ]; 
	 then
           # go through the rest of the week to Friday
           whichArg[argOne]="3"
	   whichArg[addDate]="1"
       elif [ ${dowLastBackup} == "Sun" ];  # NOTE!  THIS IS FOR A Default DATE AT THE BEGINNING OF THE YEAR, 
          then                             #        So that we don't miss the first backup on Monday. 
           whichArg[argOne]="0"
	   whichArg[addDate]="1"
       else
	   echo "ERR"
       fi

       nextStartDate=$(date --date="${lastBackup} ${whichArg[addDate]} days" +"%d %b %Y")

       echo "${whichArg[argOne]} \"${nextStartDate} 21:59:55\""

       ./updateTimes3.sh ${whichArg[argOne]} "$nextStartDate 21:59:55" 

#       ./updateTimes2.sh 3 "17 JAN 2017 21:59:55"
 
#       ./updateTimes2.sh 0 "23 JAN 2017 21:59:55" # 0 means do a backup of just the day specified in the 2nd argument. 

        unset whichArg

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


