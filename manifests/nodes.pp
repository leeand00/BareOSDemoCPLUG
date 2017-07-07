node 'bareOSdirector' {

     
     exec {'Adding user vagrant to bareos group':
		command => 'sudo usermod -G bareos vagrant',
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
	label_format => "Full-"
     }

     bareos::director::pool{'Differential':
	type => 'Backup',
	recycle => 'yes',
	auto_prune => 'yes',
	volume_retention => '90 days',
	maximum_volume_bytes => '10G',
	maximum_volume_jobs => '100',
	label_format => "Differential-"
     }


     bareos::director::pool{'Incremental':
	type => 'Backup',
	recycle => 'yes',
	auto_prune => 'yes',
	volume_retention => '30 days',
	maximum_volume_bytes => '1G',
	maximum_volume_jobs => '100',
	label_format => "Incremental-"
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
	maximum_volume_bytes => '1G',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'daily-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "daily-1", "daily-2", etc..
     }

     bareos::director::pool{'Weekly':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '28 days',       # Could use a little less or a little more about every 
					     # 4 weeks these are recycled.
	maximum_volume_bytes => '1G',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'weekly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                             #       since it's stored elsewhere in the volume meta data.
					     #       Should craete files named "weekly-1", "weekly-2", etc..
     }

     bareos::director::pool{'Monthly':
        type => 'Backup',
        recycle => 'yes',
        auto_prune => 'yes',
        volume_use_duration => '70 hours',   # 70 hours ~= 3 days
        volume_retention => '28 days',       # Could use a little less or a little more about every 
					     # 4 weeks these are recycled.
	maximum_volume_bytes => '1G',
        maximum_volumes => '10', # Should be multiplied by Maximum Volume Bytes to make sure you don't
                                 # over fill the disk or KVM Logical Volume.
     	label_format => 'monthly-${NumVols}',  # Note: There's no point in using the date variable here, 
                                               #       since it's stored elsewhere in the volume meta data.
				    	       #       Should craete files named "monthly-1", "monthly-2", etc..
     }

# Storage
     # File Storage for ${hostname}-fd backup...
     # TODO: Rename this...
     bareos::director::storage{"${hostname}_FileStorage":
	name => "${hostname}_FileStorage",
	address => $ipaddress_eth0,
	device => "${hostname}_filestorage_device",
	media_type => 'File'
     }

     # Define the main nightly save backup job
     bareos::director::job {'DefaultJob':
        name => 'DefaultJob',
	use_as_def => 'true', # Makes this a JobDef using the job template :p damn you!
	type => 'Backup',
	level => 'Incremental',
	fileset => 'SelfTest', # Forces you to remeber that you need to define a fileset in your job.
        job_schedule => 'WeeklyCycle',
	storage => "${hostname}_FileStorage",
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
        client_run_after_job => '/usr/lib/bareos/scripts/delete_catalog_backup',

        # TODO: FIGURE OUT WHERE TO SEND THIS!!! IT IS FOR DISASTER RECOVERY!
        # This sends the bootstrap via mail for disaster recovery.
        # Should be sent to another system, please change recipient accordingly
        #write_bootstrap => "|/usr/bin/bsmtp -h localhost -f \"\(Bareos\) \" -s \"Bootstrap for Job %j\" root@localhost",
       
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
	file_retention => '30 days',
	job_retention => '6 months',
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
