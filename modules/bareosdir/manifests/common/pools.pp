class bareosdir::common::pools {

# Pools
     bareos::director::pool{'Full':
	type => 'Backup',
	recycle => 'yes',
	auto_prune => 'yes',
	volume_retention => '365 days',
	maximum_volume_bytes => '50G',
	maximum_volume_jobs => '100',
	label_format => "Full-",
	storage => 'bareOSdirector_FileStorage',
     }

     bareos::director::pool{'Differential':
	type => 'Backup',
	recycle => 'yes',
	auto_prune => 'yes',
	volume_retention => '90 days',
	maximum_volume_bytes => '10G',
	maximum_volume_jobs => '100',
	label_format => "Differential-",
	storage => 'bareOSdirector_FileStorage',
     }


     bareos::director::pool{'Incremental':
	type => 'Backup',
	recycle => 'yes',
	auto_prune => 'yes',
	volume_retention => '30 days',
	maximum_volume_bytes => '1G',
	maximum_volume_jobs => '100',
	label_format => "Incremental-",
	storage => 'bareOSdirector_FileStorage',
     }

     bareos::director::pool{'Scratch':
	name => 'Scratch',
	type => 'Backup',
     }

## GFS19 Pools (from tutorial)
     bareos::director::pool{'Daily':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '4 days',
        volume_retention => '9 days',
	maximum_volume_bytes => '10G',       # NOTE: A 1G setting on this overflowed into another vol, so I'm trying 10G. 
        maximum_volume_jobs => '10',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'daily-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "daily-1", "daily-2", etc..
	storage => 'bareOSdirector_FileStorage',
     }

     bareos::director::pool{'Weekly':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '28 days',       # Could use a little less or a little more about every 
					     # 4 weeks these are recycled.
	maximum_volume_bytes => '10G',
	maximum_volume_jobs => '100',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'weekly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "weekly-1", "weekly-2", etc..
	storage => 'bareOSdirector_FileStorage',
     }

     bareos::director::pool{'Monthly':
        type => 'Backup',
        recycle => 'yes',		     # Bacula can automatically recycle volumes. 
        auto_prune => 'yes',                 # Prune expired volumes
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '362 days',      # One year
	maximum_volume_bytes => '10G',
        maximum_volume_jobs => '100', 
	maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'monthly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                               #       since it's stored elsewhere in the volume meta data.
				    	       #       Should craete files named "monthly-1", "monthly-2", etc..
	storage => 'bareOSdirector_FileStorage',
        #next_pool => 'MonthlyCopyPool',  # The destination pool for the Monthly Copy...for Copy Jobs
     }

# Off-site Backup Pools
     
    bareos::director::pool{'Offsite-Daily':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '4 days',
        volume_retention => '9 days',
	maximum_volume_bytes => '10G',       # NOTE: A 1G setting on this overflowed into another vol, so I'm trying 10G. 
        maximum_volume_jobs => '10',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'offsite-daily-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "offsite-daily-1", "offsite-daily-2", etc..
     	storage => 'bareOSremoteSD' # Set to use offsite storage...
     }

     bareos::director::pool{'Offsite-Weekly':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '28 days',       # Could use a little less or a little more about every 
					     # 4 weeks these are recycled.
	maximum_volume_bytes => '10G',
	maximum_volume_jobs => '100',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'offsite-weekly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "offsite-weekly-1", "offsite-weekly-2", etc..
     	storage => 'bareOSremoteSD' # Set to use offsite storage...
     }

     bareos::director::pool{'Offsite-Monthly':
        type => 'Backup',
        recycle => 'yes',		     # Bacula can automatically recycle volumes. 
        auto_prune => 'yes',                 # Prune expired volumes
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '362 days',      # One year
	maximum_volume_bytes => '10G',
        maximum_volume_jobs => '100', 
	maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'offsite-monthly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                               #       since it's stored elsewhere in the volume meta data.
				    	       #       Should craete files named "offsite-monthly-1", "offsite-monthly-2", etc..
     	storage => 'bareOSremoteSD' # Set to use offsite storage...
     }

#  Copy Job off-site copy destination pools
     bareos::director::pool{'MonthlyCopyPool':
        name => 'MonthlyCopyPool',
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
	volume_use_duration => '70 hours',
        volume_retention => '362 days',
        maximum_volume_bytes => '50G',
	maximum_volume_jobs => '100',
        maximum_volumes => '100',
        label_format => '${Pool}-${NumVols}',
        storage => 'bareOSdirector-monthly-CopyPool-fileStorage'
     }    

     bareos::director::pool{'WeeklyCopyPool':
        name => 'WeeklyCopyPool',
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
	volume_use_duration => '70 hours',
        volume_retention => '28 days',
        maximum_volume_bytes => '50G',
	maximum_volume_jobs => '100',
        maximum_volumes => '100',
        label_format => '${Pool}-${NumVols}',
        storage => 'bareOSdirector-weekly-CopyPool-fileStorage'
    }

     bareos::director::pool{'DailyCopyPool':
        name => 'DailyCopyPool',
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
	volume_use_duration => '4 days',
        volume_retention => '9 days',
        maximum_volume_bytes => '50G',
	maximum_volume_jobs => '100',
        maximum_volumes => '100',
        label_format => '${Pool}-${NumVols}',
        storage => 'bareOSdirector-daily-CopyPool-fileStorage'
    }
   
}
