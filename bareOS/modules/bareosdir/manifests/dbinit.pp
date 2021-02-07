class bareosdir::dbinit {

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
       mode  => '660',
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

     # Create the directory for the query.sql file.
     file{'/etc/bareos/scripts':
	ensure => directory,
	owner => bareos,
	group => bareos,
	mode => '660',
     }

     
     # Create a file with some SQL queries for finding out about your volumes etc...
     # Found this file here: https://github.com/bareos/bareos/blob/master/src/dird/query.sql
     file{'/etc/bareos/scripts/query.sql':
	content => file('bareosdir/query.sql'),
	ensure => file,
	owner => bareos,
	group => bareos,
	mode => '660',
	require => [File['/etc/bareos/scripts']],
     }

}
