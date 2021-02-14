define bareosdir::jobconfig::backupclient($clientName, $clientIpOrHostname, $includeBackupCopyJobs, $jobPriority, $copyjobPriority) {


   # There should be a 1 job to 3 pools / storage / devices... 

   # Define a backup job for the GFS
   # TODO: Make the fileset variable and define it elsewhere...

   bareos::director::job {"${clientName}-job":
	client => "${clientName}-fd",
	fileset => "${clientName}-fs", # TODO: Figure out a way to modularize this...

        # Define which pools (Full, Differential, Incremental) relate to this job.
	full_backup_pool => "${clientName}-monthly-pool",
	diff_backup_pool => "${clientName}-daily-pool",
        # inc_backup_pool => "${clientName}-daily-pool",
	job_schedule => "${clientName}-cycle-schedule",
	priority => $jobPriority, # Note that this should be a number lower than the 
			 	  # backup copy job, since it should run before it, 
			 	  # so that the backup copy job has something to copy immediately.
				  # (it was 8)
   }


if $includeBackupCopyJobs == true {

   # There should be a 1 job to 3 pools / storage / devices

   # Define a single job for the backup copy jobs
   bareos::director::job {"${clientName}-CopyJob":
   	type => "Copy",
        jobdef => "DefaultJob",
        pool => "Scratch",
	full_backup_pool => "${clientName}-monthly-CopyPool",
	diff_backup_pool => "${clientName}-daily-CopyPool",
	#storage => "File-${clientName}-${whichGFS}-CopyPool",
	job_schedule => "${clientName}-cp-cycle-schedule-copypool",   
	selection_type => "PoolUncopiedJobs",
	priority => $copyjobPriority, # Note this should be a number higher than the backup job
  			              # so that it gets run after it, and copies over what was 
                   		      # just backed up immediately.
				      # (it was 9)

			 # priority 10 should be the BareOSdirector backup...
			 # priority 11 should be the Catalog backup (it should be the last thing that gets backed up) 
   }

   # Define a single schedule for the backup copy jobs
   # (with three different backups)
   bareos::director::schedule{"${clientName}-cp-cycle-schedule-copypool":

	  run_spec => [
		       # ------------------------------------------------------------------- 
		       # Copy Job Schedule
		       ['Full', "Pool=${clientName}-monthly-pool NextPool=${clientName}-monthly-CopyPool 1st friday", "22:00"], # 12pm (noon)
		       ['Full', "Pool=${clientName}-weekly-pool NextPool=${clientName}-weekly-CopyPool 2nd-5th friday", "22:00"], # 12pm (noon)
		       ['Differential', "Pool=${clientName}-daily-pool NextPool=${clientName}-daily-CopyPool monday-thursday", "22:00"], # 12pm (noon)
	      ],
	}

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
	mode => '660',
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


# TODO: Get the schedule ironed out...
if $includeBackupCopyJobs == true {

	bareos::director::schedule{"${clientName}-cycle-schedule":

	  run_spec => [
		       # BEGIN test of "first backup should be a full monthly backup...otherwise the differentials have nothing to restore from."
		       # TODO: Make this the 1st Monday in JAN!!! IT WILL WORK BETTER!!!!
		       #['Full', "Pool=${clientName}-monthly-pool NextPool=${clientName}-monthly-CopyPool  jan 2", '22:00'], 
		       # END test of "first backup should be a full monthly backup..."

		       ['Differential', "Pool=${clientName}-daily-pool NextPool=${clientName}-daily-CopyPool monday-thursday", '22:00'], # 10pm
	       	       ['Full', "Pool=${clientName}-weekly-pool  NextPool=${clientName}-weekly-CopyPool 2nd-5th friday", '22:00'], 
		       ['Full', "Pool=${clientName}-monthly-pool NextPool=${clientName}-monthly-CopyPool 1st friday", '22:00'],
	      ],
	}

} else {

	bareos::director::schedule{"${clientName}-cycle-schedule":

	  run_spec => [
		       # BEGIN test of "first backup should be a full monthly backup...otherwise the differentials have nothing to restore from."
		       # TODO: Make this the 1st Monday in JAN!!! IT WILL WORK BETTER!!!!
		       #['Full', "Pool=${clientName}-monthly-pool  jan 2", '22:00'], 
		       # END test of "first backup should be a full monthly backup..."

		       ['Differential', "Pool=${clientName}-daily-pool monday-thursday", '22:00'], # 10pm
	       	       ['Full', "Pool=${clientName}-weekly-pool  2nd-5th friday", '22:00'], 
		       ['Full', "Pool=${clientName}-monthly-pool 1st friday", '22:00'],
	      ],
	}
} 


   # NOTE: Don't forget to add this to the schedule...in schedule.pp

  

}
