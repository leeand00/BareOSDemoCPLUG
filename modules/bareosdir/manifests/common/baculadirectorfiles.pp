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
        client => "${hostname}-fd",
        fileset => 'bacula_files_backup',
     }

     # File Storage for ${hostname}-fd backup...
     # TODO: Rename this...
     bareos::director::storage{"${hostname}_FileStorage":
	name => "${hostname}_FileStorage",
	address => $ipaddress_eth2,
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
	exclude => ['/var/lib/bareos', '/var/lib/mysql'],
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
     bareos::director::job {'MonthlyBackupCopy':
        name => 'MonthlyBackupCopy',
        type => 'Copy',     # Copy the jobs from the local to the remote
        pool => 'Monthly',  # Source Pool
        storage => 'File2', # Destination Storage
        selection_type => 'PoolUncopiedJobs',
     }

     # Add the storage for the CopyJobs
     # Used to copy jobs to a remote storage daemon
     # from the local director.
     bareos::director::storage{"File2":
        name => "File2",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr2",
	media_type => "File4",
	max_concurrent => "5", # Max Concurrent Jobs...
     }

}
