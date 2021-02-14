class bareosdir::common::baculadirectorfiles {

###### Generic Jobs ######
     # Backup the catalog database (after the nightly save)
     bareos::director::job {'RestoreFiles':
        name => 'RestoreFiles',
	job_schedule => '',
    	type => 'Restore',
        client => "${hostname}-fd",
        fileset => 'LinuxAll',
	# If you're going to restore files, you should select the storage you're going to use.
        # storage => "${hostname}_FileStorage",
        pool => 'Incremental',
        messages => 'standard',
        where => '/tmp/bareos-restores',
	enabled => 'no',  # Permanently disables scheduling of the job. (between reloads, you can always disable it)
     }

###### Bacula Director Local Backup Jobs #####

     # Define the main nightly save backup job
     bareos::director::job {'BaculaDirectorDirFiles':
        name => 'BaculaDirectorDirFiles',
	full_backup_pool => 'Monthly',
	diff_backup_pool => 'Daily',
	# inc_backup_pool => '',
        client => "${hostname}-fd",
        fileset => 'bacula_files_backup',
	job_schedule => 'WeeklyCycle',
	priority => '10',
     }

     # File Storage for ${hostname}-fd backup...
     # TODO: Rename this...
     bareos::director::storage{"${hostname}_FileStorage":
	name => "${hostname}_FileStorage",
	#address => $ipaddress_eth2,
        address => $facts['networking']['interfaces']['eth0']['ip'],
	device => "${hostname}_filestorage_device",
	media_type => 'File',
	autochanger => 'yes',
     }

     # The directors local file storage
     bareos::storage::device {"${hostname}_filestorage_device":
#       device_type => '',
        media_type => 'File',
        archive_device => "/mnt/backups/${hostname}",
        label_media => 'yes',
        random_access => 'yes',
        automatic_mount => 'yes',
        removable_media => 'no',
        always_open => 'yes',
        
     }
     
     # Fileset for backing up the bacula server itself.
     bareos::director::fileset{'bacula_files_backup':
	name => 'bacula_files_backup',
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'],
        # Backup Configuration and Server Logs...
        include => ['/etc/', '/var/'],

	# Exclude bareos lib, and Catalog Backup Directory...
        # NOTE: The Catalog is backed up with the CatalogBackup, and not this.
	exclude => ['/var/lib/bareos', '/var/lib/postgresql'],
     }

######## Remote Storage Deamon ##############

#### Remote Backup Job ####
     # Add the storage for the bareOSremoteSD
     # (Used to store jobs on a remote storage daemon)
     bareos::director::storage{"bareOSremoteSD":
        name => "bareOSremoteSD",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr1",
	media_type => "File1",
	max_concurrent => "10", # Max Concurrent Jobs...
     }


#### Remote Backup Copy Job ####

     # Copy Backup Files to Remote Storage
     bareos::director::job {'BaculaDirectorDirFilesCopy':
        name => 'BaculaDirectorDirFilesCopy',
        type => 'Copy',     # Copy the jobs from the local to the remote
        pool => 'Scratch',  # Source Pool
	job_schedule => 'WeeklyCycleCopy',
        #storage => 'bareOSdirector-monthly-CopyPool-fileStorage', # Destination Storage
        selection_type => 'PoolUncopiedJobs',
	priority => '12',  # Should run after BaculaDirectorDirFilesCopy and so
			   # we set it to 12.
     }



     # Add the storage for the CopyJobs
     # Used to copy jobs to a remote storage daemon
     # from the local director.
     bareos::director::storage{"bareOSdirector-monthly-CopyPool-fileStorage":
        name => "bareOSdirector-monthly-CopyPool-fileStorage",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr-File-bareOSdirector-monthly-CopyPool-Dev1",
	media_type => "File4",
	max_concurrent => "5", # Max Concurrent Jobs...
     }


     # Add the storage for the CopyJobs
     # Used to copy jobs to a remote storage daemon
     # from the local director.
     bareos::director::storage{"bareOSdirector-weekly-CopyPool-fileStorage":
        name => "bareOSdirector-weekly-CopyPool-fileStorage",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr-File-bareOSdirector-weekly-CopyPool-Dev1",
	media_type => "File4",
	max_concurrent => "5", # Max Concurrent Jobs...
     }

     # Add the storage for the CopyJobs
     # Used to copy jobs to a remote storage daemon
     # from the local director.
     bareos::director::storage{"bareOSdirector-daily-CopyPool-fileStorage":
        name => "bareOSdirector-daily-CopyPool-fileStorage",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr-File-bareOSdirector-daily-CopyPool-Dev1",
	media_type => "File4",
	max_concurrent => "5", # Max Concurrent Jobs...
     }

#     bareos::director::job {'WeeklyBackupCopy':
#        name => 'WeeklyBackupCopy',
#        type => 'Copy',     # Copy the jobs from the local to the remote
#        pool => 'Weekly',  # Source Pool
#        storage => 'bareOSdirector-weekly-CopyPool-fileStorage', # Destination Storage
#        selection_type => 'PoolUncopiedJobs',
#     }
#
#     # Add the storage for the CopyJobs
#     # Used to copy jobs to a remote storage daemon
#     # from the local director.
#     bareos::director::storage{"bareOSdirector-weekly-CopyPool-fileStorage":
#        name => "bareOSdirector-weekly-CopyPool-fileStorage",
#	address => "bareOSremoteSD",  # TODO: See if this works...
#	password => "storage_password",
#	sd_port => '9103',
#        device => "FileChgr2",
#	media_type => "File4",
#	max_concurrent => "5", # Max Concurrent Jobs...
#     }
#
#
#     bareos::director::job {'DailyBackupCopy':
#        name => 'DailyBackupCopy',
#        type => 'Copy',     # Copy the jobs from the local to the remote
#        pool => 'Daily',  # Source Pool
#        storage => 'bareOSdirector-weekly-CopyPool-fileStorage', # Destination Storage
#        selection_type => 'PoolUncopiedJobs',
#     }
#
#     # Add the storage for the CopyJobs
#     # Used to copy jobs to a remote storage daemon
#     # from the local director.
#     bareos::director::storage{"bareOSdirector-weekly-CopyPool-fileStorage":
#        name => "bareOSdirector-weekly-CopyPool-fileStorage",
#	address => "bareOSremoteSD",  # TODO: See if this works...
#	password => "storage_password",
#	sd_port => '9103',
#        device => "FileChgr2",
#	media_type => "File4",
#	max_concurrent => "5", # Max Concurrent Jobs...
#     }

}
