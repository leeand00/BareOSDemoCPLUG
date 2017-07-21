node 'bareOSdirector' {

     # Allow email to be sent from this bareOSdirector
     # to my gmail account.
     include postfix
     
     # Include bareos-tools
     # For instance bls and bextract...
     # Note: Not sure if these really need to be included in a production server
     #       since you use these tools when the production server needs a disaster 
     #       recovery...but when reading up on this and doing tutorials they came 
     #       up and were not installed, so I am installing them here.
     #
     #include bareostools
     # TODO: Fix this so that you can get that class working should you need it...
     package {'bareos-tools':
	ensure => installed,
     }

     exec {'Adding user vagrant to bareos group':
		command => 'sudo usermod -G vagrant,bareos vagrant',
		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin',
		cwd	=> '/home/vagrant',
     }

     file { [  '/mnt/backups', "/mnt/backups/${hostname}" ]:
       ensure => 'directory',
       owner => bareos,
       group => bareos,
       mode  => 660,
     }


     # See: http://linuxpitstop.com/install-bareos-backup-solution-on-centos-7/
     # This is done so that the scripts may run to install the database
     # in the next three steps.
     file {'/root/.my.cnf':
	   content => "[client]\nhost=localhost\nuser=root\npassword=turnkeyAvB12",
           owner => root,
           group => root,
           mode  => 660,           
     }

     # See: http://linuxpitstop.com/install-bareos-backup-solution-on-centos-7/
     # This is done so that the scripts may run to install the database
     # in the next three steps.
     file {'/home/vagrant/.my.cnf':
	   content => "[client]\nhost=localhost\nuser=root\npassword=turnkeyAvB12",
           owner => vagrant,
           group => vagrant,
           mode  => 660           
     }

     exec {'Creating Database':
                environment => ["db_name=bareos", "db_user=root", "HOME=/root"], # Need to set $HOME correctly: https://groups.google.com/d/msg/puppet-users/PBUGMq2KGBA/Z1mhm1lysWcJ 
		command => 'create_bareos_database',
		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/usr/lib/bareos/scripts',
		cwd	=> '/usr/lib/bareos/scripts',
		creates => '/var/lib/mysql/bareos',
		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
		require => [File["/root/.my.cnf"],File["/home/vagrant/.my.cnf"],Package["bareos-database-mysql"]]  # Make sure that bareos is installed before installing the packages...
     }
 
     exec {'Creating Tables':
		environment => ["db_name=bareos", "db_user=root", "HOME=/root"],
		command => 'make_bareos_tables',
		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/usr/lib/bareos/scripts',
		cwd	=> '/usr/lib/bareos/scripts',
		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
		require => [Exec['Creating Database']],
     }

     exec {'Granting Privileges':
		environment => ["db_name=bareos", "db_user=root", "db_password=turnkeyAvB12", "db_driver=mysql",  "HOME=/root"],
		command => 'grant_bareos_privileges',
		path    => '/sbin/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/usr/lib/bareos/scripts',
		cwd	=> '/usr/lib/bareos/scripts',
		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
		require => [Exec['Creating Tables']],
     }

     file{'/etc/bareos/bareos-dir.d/catalog/MyCatalog.conf':
	ensure => absent,
	require => Package["bareos-database-mysql"],
     }

     class {'bareos':
           manage_client => true,
           manage_storage => true,
           manage_director => true,
           manage_console => true,
#          manage_database => true,
           default_password => '***REMOVED***',
	   director_template => 'bareos/bareos-dir.conf.erb',
           storage_template => 'bareos/bareos-sd.conf.erb',
	   client_template => 'bareos/bareos-fd.conf.erb',
           console_template => 'bareos/bconsole.conf.erb',

           client_address => $ipaddress_eth0,

           version => '16.2.4-12.1',
           
           console_password => '***REMOVED***',
      
           database_host => '127.0.0.1',
	   database_port => 3306,
	   database_user => 'root',
           database_password => 'turnkeyAvB12',
           database_name => 'bareos',
           database_backend => 'mysql',
	   director_name => "${hostname}",
           default_jobdef => 'DefaultJob',
           noops => false,
     }


     # Creates a catalog...
     bareos::director::catalog {'MyCatalog':
		name => 'MyCatalog',
                db_user => 'root',
		db_name => 'bareos',
		db_password => 'turnkeyAvB12',
                db_driver => 'mysql',
     }

     bareos::director::messages{'standard':
	name => 'standard',
        mail_command => '/usr/bin/mail',
	mail_from => 'helpdeskaleer@gmail.com',
	mail_to => 'helpdeskaleer@gmail.com',	
     }

     bareos::director::messages{'Daemon':
	name => 'Daemon',
     }

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

## GFS?? Pools (from tutorial)
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

# Storage
     # File Storage for ${hostname}-fd backup...
     # TODO: Rename this...
     bareos::director::storage{"${hostname}_FileStorage":
	name => "${hostname}_FileStorage",
	address => $ipaddress_eth0,
	device => "${hostname}_filestorage_device",
	media_type => 'File',
	autochanger => 'yes',
     }

     # Add the storage for the bareOSremoteSD
     bareos::director::storage{"bareOSremoteSD":
        name => "bareOSremoteSD",
	address => "bareOSremoteSD",  # TODO: See if this works...
	password => "storage_password",
	sd_port => '9103',
        device => "FileChgr1",
	media_type => "File1",
	max_concurrent => "10", # Max Concurrent Jobs...
	
     }

     # Define the main nightly save backup job
     bareos::director::job {'DefaultJob':
        name => 'DefaultJob',
	use_as_def => 'true', # Makes this a JobDef using the job template :p damn you!
	type => 'Backup',
	level => 'Incremental',
	fileset => 'SelfTest', # Forces you to remeber that you need to define a fileset in your job.
        job_schedule => 'WeeklyCycle',
        # Note: I removed storage from the Default JobDef because it confuses people.
	#storage => "${hostname}_FileStorage",
	messages => 'standard',
	pool => 'Daily',
	priority => '10',
	write_bootstrap => '/var/lib/bareos/%c.bsr',
# TODO: WHAT THE HELL?!?!#?
	full_backup_pool => 'Full',
	diff_backup_pool => 'Differential',
        inc_backup_pool => 'Incremental',
     }


     # Define the main nightly save backup job
     bareos::director::job {'BaculaDirectorDirFiles':
        name => 'BaculaDirectorDirFiles',
        client => "${hostname}-fd",
        fileset => 'bacula_files_backup',
     }

     # Backup the catalog database (after the nightly save)
     bareos::director::job {'BackupCatalog':
        name => 'BackupCatalog',
        client => "${hostname}-fd",
	level => 'Full',
        fileset => 'Catalog',
	job_schedule => 'WeeklyCycle',


        # This creates an ASCII copy of the catalog
        # Arguments to make_catalog_backup.pl are:
        # make_catalog_backup.pl <catalog-name>
        client_run_before_job => '/usr/lib/bareos/scripts/make_catalog_backup.pl MyCatalog',
        
        # Somewhere in the tutorial he said to comment this out...so you can pick it up
        # later if something goes wrong.
        #client_run_after_job => '/usr/lib/bareos/scripts/delete_catalog_backup',

        #write_bootstrap => "|/usr/bin/bsmtp -h localhost -f \"\(Bareos\) \" -s \"Bootstrap for Job %j\" root@localhost",

	# THIS IS FOR DISASTER RECOVERY OF THE BACKUP SERVER!
	# This is from http://www.binarytides.com/linux-mail-command-examples/
	# "2. Subject and Message in a single line"   
 	write_bootstrap => "|/usr/bin/mail -s \\\"Bareos: Bootstrap file for Job ID:  %j\\\" 'helpdeskaleer@gmail.com' <<< 'helpdeskaleer@gmail.com",

        # NOTE: They also say you should write out one of these with every job that you run, 
        #       to avoid running bscan on disaster recovery.
	# ALSO NOTE: If you wish to write it out to a file on a mounted smb share instead
	#            use the following line:
	#write_bootstrap => "/var/lib/bareos/%n.bsr", # This works, but it nly writes out a file...
       
  	# NOTE: This job MUST be run after all the other jobs have run.
     	#       This is accomplished by setting it to a priority number higher
        #       than the rest of the jobs.
        # run after main backup
	priority => '11',
     }

     
     # Backup the catalog database (after the nightly save)
     bareos::director::job {'RestoreFiles':
        name => 'RestoreFiles',
	job_schedule => '',
    	type => 'Restore',
        client => "${hostname}-fd",
        fileset => 'LinuxAll',
        storage => "${hostname}_FileStorage",
        pool => 'Incremental',
        messages => 'standard',
        where => '/tmp/bareos-restores',
	enabled => 'no',  # Permanently disables scheduling of the job. (between reloads, you can always disable it)
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

     # Fileset for backing up the bacula catalog:
     bareos::director::fileset{'Catalog':
	name => 'Catalog',

        # Pick up the database dump (see the BackupCatalog job for details. 
        include => ['/var/lib/bareos/bareos.sql'],
     }


     # Generic file sets
     # One for Linux
     bareos::director::fileset{'LinuxAll':
	name => 'LinuxAll',
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'], 
        include => ['/'],

        # Things that usually have to be excluded
	# You have to exclude /var/lib/bareos/storage on your bareos server

        # TODO: Add /mnt/Backups if it's a mount you're adding with lvm:
        exclude => ['/var/lib/bareos', '/var/lib/bareos/storage', '/proc', '/tmp', '.journal', '.fsck'],
     } 


     # Fileset for self testing
     bareos::director::fileset{'SelfTest':
	name => 'SelfTest',
        include => ['/usr/sbin'],
     }

     # Schedule
     bareos::director::schedule{'WeeklyCycle':
       name => 'WeeklyCycle',
       
#       run_spec => [['Differential', 'Pool = Daily', 'monday-thursday', '20:00'], # 8pm
#                    ['Differential', '2nd-5th sat', '23:05'], 
#                    ['Incremental', 'mon-fri', '23:05']],

       run_spec => [
                    ['Differential', 'Pool=Daily monday-thursday', '23:30'], # 11pm (sons)
                    ['Full', 'Pool=Weekly 2nd-5th Friday', '23:30'], # 11pm (fathers)  
								     # Note: 2nd - 5th Friday because some months have 5 fridays in them.
                    ['Full', 'Pool=Monthly 1st Friday', '23:30'] # First Friday of the month Montly backup is done.
								 # 11pm (grandfathers)

                   ], 
     } 

     # Client (File Services) to backup
     bareos::director::client {"${hostname}-fd":
	name => "${hostname}-fd",
        address => $ipaddress_eth0,
	catalog => 'MyCatalog',  # See `Creates a catalog...`
	file_retention => '6 months',  # Should be 6 months or so until you learn bacula better. 
	job_retention => '1 year',     # Should be equal to your maximum volume_retention (see the Monthly pool)
     }

     

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


     exec {'Setting Time':
		command => 'sudo date -s \"1 JAN 2017 01:00:00\"',
		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin',
		cwd	=> '/home/vagrant',
		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
     }

# We must stop this service so that
# we can set the date when testing 
# backup configuarions.
#
# Note: you may also be required to run "VBoxManage setextradata "VM name" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1"
# to keep the date from being set
#
# Note: If it becomes evident that you need this vboxadd-service,
#       you can do this to disable the timesync with the host:
#       https://stackoverflow.com/a/38657239  
#        
     service {'vboxadd-service':
	ensure => 'stopped',
     }

}

node 'bareOSremoteSD' {

	class {'bareos':
	      manage_client => true,
	      manage_storage => true,
	      manage_director => false,
	      manage_console => false,
	      manage_database => false,
	      default_password => '***REMOVED***',
	      storage_template => 'bareos/bareos-sd.conf.erb',
	      client_template => 'bareos/bareos-fd.conf.erb',
	      client_address => $ipaddress_eth2,
	      version => '16.2.4-12.1',
	      noops => false,

	      # Configure the off-site storage daemon
	      storage_name => "${hostname}",
	      storage_address => $ipaddress_eth2,
	      storage_max_concurrent => 20,
	      director_name => 'bareOSdirector',  # TODO: Find a way to get this directly form the node above.
	      storage_password => "storage_password",
	}

	file {'/etc/bareos/storage.d/FileChgr1.conf':
	     content => file("bareos/FileChgr1"),
	     owner => bareos,
 	     group => bareos,
             mode => 660,
	}

        file { [  '/mnt/backups', "/mnt/backup" ]:
     	     ensure => 'directory',
             owner => bareos,
             group => bareos,
             mode  => 660,
        }

}

node 'webserver' {

    class{'bareos':
           manage_client => true,
           manage_storage => false,
           manage_director => false,
           manage_console => false,
           version => '16.2.4-12.1',
           noops => false,
    }

    file {'/tmp/nginx.txt':
          content => "nginx\n",
          owner => root,
          mode => 775,
    }
}

node default {
    notify {'Default Node':

    }
}
