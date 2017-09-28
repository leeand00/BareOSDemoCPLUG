define bareosdir::jobconfig::backupclient($clientName, $clientIpOrHostname, $includeBackupCopyJobs) {


   # There should be a 1 job to 3 pools / storage / devices... 

   # Define a backup job for the GFS
   # TODO: Make the fileset variable and define it elsewhere...

   bareos::director::job {"${clientName}-job":
	client => "${clientName}-fd",
	fileset => "${clientName}-fs", # TODO: Figure out a way to modularize this...

        # Define which pools (Full, Differential, Incremental) relate to this job.
	full_backup_pool => "${clientName}-monthly-pool",
	diff_backup_pool => "${clientName}-daily-pool",
        inc_backup_pool => "${clientName}-daily-pool",
	job_schedule => "${clientName}-cycle-schedule",
   }

   # Define a client file daemon in the bareos director config
   bareos::director::client {"${clientName}-fd":
	address => $clientIpOrHostname,
	catalog => 'MyCatalog',  # See `Creates a catalog...` 
	file_retention => '6 months', # Should be 6 months or so until you learn bacula better. 
	job_retention => '1 year',    # Should be equal to your maximum volume_retention (see the Monthly pool)
   }


    # Generates directories for storage of volumes
    file {"/mnt/backups/${clientName}":
	ensure => 'directory',
	owner => bareos,
	group => bareos,
	mode => 660,
   }

   # Define what you want to name the following:
   # - Grandfathers (monthly)
   # - Fathers (weekly)
   # - Sons (daily)
   $GFS = {
	"s${clientName}" => {
		gfs_obj_label => 'daily',
		recycle => 'yes',
		auto_prune => 'yes',
		volume_use_duration => '4 days',
		volume_retention => '9 days',
		maximum_volume_bytes => '10G',  # Note: A 1G setting on this overflowed into another vol, so I'm trying 10G.
		maximum_volume_jobs => '10',
		maximum_volumes => '10',  # Should be multipled by Maximum Volume Bytes to make sure you don't
					  # over fill the disk or KVM Logical Volume.
		#copy_job_schedule_days => 'tuesday-saturday', # NOTE: Since this is GFS 19...we can't do this...
							       # Because the volume is only marked Used after 
							       # the following Monday...and thus during the first week there is 
							       # NOTHING to copy on the daily...!!!!
		copy_job_schedule_days => 'monday',            # So instead we'll do this on Monday...but the first one will not do anything.
							       # The first Daily Copy Job will occur on the 9th or maybe the 16th...with GFS19
		copy_job_schedule_time => '12:00',	
	},
	"g${clientName}" => {
		gfs_obj_label => 'monthly',
		recycle => 'yes',		   # Bareos can automatically recycle volumes.
		auto_prune => 'yes',		   # Purne expired volumes.
		volume_use_duration => '70 hours', # 70 hours ~= 3 days
		volume_retention => '362 days',    # One year 
		maximum_volume_bytes => '10G',
		maximum_volume_jobs => '100',
		maximum_volumes => '12',	   # Should be multiplied by Maximum Volume Bytes to make sure you don't 
						   # over fill the disk or KVM Logical Volume.
						   # This was set to 10, but I believe since it's a monthly backup
						   # it should be set to 12 at least.
		copy_job_schedule_days => '1st saturday',
		copy_job_schedule_time => '12:00',	
	},
	"f${clientName}" => {
		gfs_obj_label => 'weekly',
		recycle => 'yes',
		auto_prune => 'yes',
		volume_use_duration => '70 hours',
		volume_retention => '28 days',
		maximum_volume_bytes => '10G',
		maximum_volume_jobs => '100',
		maximum_volumes => '10',  # Should be multiplied by Maximum Volume Bytes to make sure you don't
					 # over fill the disk or KVM Logical Volume.
		copy_job_schedule_days => '2nd-5th saturday',
		copy_job_schedule_time => '12:00',	
	},
   }

   $gfsKeys = keys($GFS)


   # Setup GFS19 Pools, Storage, and Devices...
   bareosdir::jobconfig::backupclientlocalconfig {$gfsKeys:
       clientName => $clientName,
       clientIpOrHostname => $clientIpOrHostname,
       backupBasePath => "/mnt/backups",
       includeBackupCopyJobs => $includeBackupCopyJobs,
       gfsHash => $GFS,
   }

# TODO: Setup remote backups...

	bareos::director::schedule{"${clientName}-cycle-schedule":

	  run_spec => [
		       # BEGIN test of "first backup should be a full monthly backup...otherwise the differentials have nothing to restore from."
		       # TODO: Make this the 1st Monday in JAN!!! IT WILL WORK BETTER!!!!
		       ['Full', "Pool=${clientName}-monthly-pool NextPool=${clientName}-monthly-CopyPool  jan 2", '22:00'], 
		       # END test of "first backup should be a full monthly backup..."

		       ['Differential', "Pool=${clientName}-daily-pool NextPool=${clientName}-daily-CopyPool monday-thursday", '22:00'], # 10pm
	       	       ['Full', "Pool=${clientName}-weekly-pool  NextPool=${clientName}-weekly-CopyPool 2nd-5th friday", '22:00'], 
		       ['Full', "Pool=${clientName}-monthly-pool NextPool=${clientName}-monthly-CopyPool 1st friday", '22:00'],
	      ],
	}

# TODO: Get the schedule ironed out...
if $includeBackupCopyJobs == true {


#	bareos::director::schedule{"${clientName}-cycle-schedule-copypool":
#
#	  run_spec => [
#		       # ------------------------------------------------------------------- 
#		       # Copy Job Schedule
#		       ['Full', "Pool=${clientName}-daily-CopyPool tuesday-saturday", '12:00'], # 12pm (noon)
#	       	       ['Full', "Pool=${clientName}-weekly-CopyPool 2nd-5th saturday", '12:00'], 
#          	       ['Full', "Pool=${clientName}-monthly-CopyPool 1st saturday", '12:00'],
#	      ],
#	}

} 


   # NOTE: Don't forget to add this to the schedule...in schedule.pp

  

}
