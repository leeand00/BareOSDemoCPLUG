define bareosdir::jobconfig::backupclientlocalconfig($clientName, $clientIpOrHostname, $backupBasePath, $includeBackupCopyJobs, $gfsHash) {

    $clientBackupPath = "${backupBasePath}/${clientName}"  

    # Obtain the GFS object from the Hash...
    $whichGFSobj = $gfsHash[$name]    

    # Obtain the label of the object from the object...
    $whichGFS = $whichGFSobj['gfs_obj_label']

    if $includeBackupCopyJobs == true {
       $whichCopyJobDays = $whichGFSobj['copy_job_schedule_days']
       $whichCopyJobTime = $whichGFSobj['copy_job_schedule_time']
    }
    
 
    notify {"${name}_notify":
	message => "${whichGFS}"
    } 

    # Generates directories for storage of volumes
    file {"${clientBackupPath}/${whichGFS}":
	ensure => 'directory',
	owner => bareos,
	group => bareos,
	mode => 660,
	require => [File["${clientBackupPath}"]],
    }
   
   bareos::director::storage{"${clientName}-${whichGFS}-fileStorage":
	address => $ipaddress_eth2,
	device => "${clientName}-${whichGFS}-device",
	media_type => 'File',
	autochanger => 'yes',  # TODO: See if this is necessary
   }

   bareos::storage::device {"${clientName}-${whichGFS}-device":
	media_type => 'File',
	archive_device => "${clientBackupPath}/${whichGFS}",
	label_media => 'yes',
	random_access => 'yes',
	automatic_mount => 'yes',
	removable_media => 'no',
	always_open => 'yes',
   }    


if $includeBackupCopyJobs == true {

     bareos::director::pool{"${clientName}-${whichGFS}-pool":
        type => 'Backup',
        recycle => $whichGFSobj['recycle'],
        auto_prune => $whichGFSobj['auto_prune'],
        volume_use_duration => $whichGFSobj['volume_use_duration'],
        volume_retention => $whichGFSobj['volume_retention'],
	maximum_volume_bytes => $whichGFSobj['maximum_volume_bytes'],       # NOTE: A 1G setting on this overflowed into another vol, so I'm trying 10G. 
        maximum_volume_jobs => $whichGFSobj['maximum_volume_jobs'],
        maximum_volumes => $whichGFSobj['maximum_volumes'], # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => "${clientName}-${whichGFS}-volnum-\\$\\{NumVols\\}",  # Note: There's no point in using the date variable here, 
        				                                      #       since it's stored elsewhere in the volume meta data.
					 				      #       Should craete files named "daily-1", "daily-2", etc..
	storage => "${clientName}-${whichGFS}-fileStorage",
	next_pool => "${clientName}-${whichGFS}-CopyPool",
    }



} 
else 
{
     bareos::director::pool{"${clientName}-${whichGFS}-pool":
        type => 'Backup',
        recycle => $whichGFSobj['recycle'],
        auto_prune => $whichGFSobj['auto_prune'],
        volume_use_duration => $whichGFSobj['volume_use_duration'],
        volume_retention => $whichGFSobj['volume_retention'],
	maximum_volume_bytes => $whichGFSobj['maximum_volume_bytes'],       # NOTE: A 1G setting on this overflowed into another vol, so I'm trying 10G. 
        maximum_volume_jobs => $whichGFSobj['maximum_volume_jobs'],
        maximum_volumes => $whichGFSobj['maximum_volumes'], # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => "${clientName}-${whichGFS}-volnum-\\$\\{NumVols\\}",  # Note: There's no point in using the date variable here, 
				                                              #       since it's stored elsewhere in the volume meta data.
								  	      #       Should craete files named "daily-1", "daily-2", etc..
	storage => "${clientName}-${whichGFS}-fileStorage",     
    }
}

if $includeBackupCopyJobs == true {

   bareos::director::job {"${clientName}-${whichGFS}-CopyJob":
   	type => "Copy",
        jobdef => "DefaultJob",
        pool => "${clientName}-${whichGFS}-pool",
	storage => "File-${clientName}-${whichGFS}-CopyPool",
	job_schedule => "${clientName}-${whichGFS}-cycle-schedule-copypool",   
	selection_type => "PoolUncopiedJobs",
   }
 
   bareos::director::schedule{"${clientName}-${whichGFS}-cycle-schedule-copypool":

	  run_spec => [
		       # ------------------------------------------------------------------- 
		       # Copy Job Schedule
		       ['Full', "Pool=${clientName}-${whichGFS}-pool NextPool=${clientName}-${whichGFS}-CopyPool ${whichCopyJobDays}", "${whichCopyJobTime}"], # 12pm (noon)
	      ],
	}

     # Copy Job off-site copy destination pools
     bareos::director::pool{"${clientName}-${whichGFS}-CopyPool":
        name => "${clientName}-${whichGFS}-CopyPool",
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_retention => '365 days',
        maximum_volume_bytes => '50G',
	maximum_volume_jobs => '100',
        maximum_volumes => '100',
        label_format => '${Pool}-${NumVols}',
        storage => "File-${clientName}-${whichGFS}-CopyPool",
     } 

     # Used to copy jobs to a remote storage daemon
     # from the local director.
     bareos::director::storage{"File-${clientName}-${whichGFS}-CopyPool":
        name => "File-${clientName}-${whichGFS}-CopyPool",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr-File-${clientName}-${whichGFS}-CopyPool",
	media_type => "File4",
	max_concurrent => "5", # Max Concurrent Jobs...
     }
}

#
#   file {$clientBackupPath:
#	ensure => 'directory',
#	owner => bareos,
#	group => bareos,
#	mode => 660
#   }
#
#   file {$GFSarr:
#	ensure => 'directory',
#	owner => bareos,
#	group => bareos,
#	mode => 660
#   }
#
#  # Begin GFS19 Pools
### GFS19 Pools (from tutorial)
#     bareos::director::pool{"Daily-${clientName}":
#        type => 'Backup',
#        recycle => 'yes',
#        auto_prune => 'yes',
#        volume_use_duration => '4 days',
#        volume_retention => '9 days',
# 	 maximum_volume_bytes => '10G',       # NOTE: A 1G setting on this overflowed into another vol, so I'm trying 10G. 
#        maximum_volume_jobs => '10',
#        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
#                                 # over fill the disk or KVM Logical Volume.
#     	label_format => "daily-${clientName}-\\$\\{NumVols\\}",  # Note: There's no point in using the date variable here, 
#                                             #       since it's stored elsewhere in the volume meta data.
#					     #       Should craete files named "daily-1", "daily-2", etc..
#	storage => "${clientName}_fileStorage",
#     }
#
#     bareos::director::pool{"Weekly-${clientName}":
#        type => 'Backup',
#        recycle => 'yes',
#        auto_prune => 'yes',
#        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
#        volume_retention => '28 days',       # Could use a little less or a little more about every 
#					     # 4 weeks these are recycled.
#	maximum_volume_bytes => '10G',
#	maximum_volume_jobs => '100',
#        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
#                                 # over fill the disk or KVM Logical Volume.
#     	label_format => "weekly-${clientName}-\\$\\{NumVols\\}",  # Note: There's no point in using the date variable here, 
#                                             #       since it's stored elsewhere in the volume meta data.
#					     #       Should craete files named "weekly-1", "weekly-2", etc..
#	storage => "${clientName}_fileStorage",
#     }
#
#     bareos::director::pool{"Monthly-${clientName}":
#        type => 'Backup',
#        recycle => 'yes',		     # Bacula can automatically recycle volumes. 
#        auto_prune => 'yes',                 # Prune expired volumes
#        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
#        volume_retention => '362 days',      # One year
#	maximum_volume_bytes => '10G',
#        maximum_volume_jobs => '100', 
#	maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
#                                 # over fill the disk or KVM Logical Volume.
#     	label_format => "monthly-${clientName}-\\$\\{NumVols\\}",  # Note: There's no point in using the date variable here, 
#                                               #       since it's stored elsewhere in the volume meta data.
#				    	       #       Should craete files named "monthly-1", "monthly-2", etc..
#	storage => "${clientName}_fileStorage",
#  
#        # TODO: Add the remote storage daemon copy backup job...
##        next_pool => 'MonthlyCopyPool',  # The destination pool for the Monthly Copy...for Copy Jobs
#     }
  
}
