class bareosdir::common {

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

           client_address => $facts['networking']['interfaces']['eth0']['ip'],
           storage_address => $facts['networking']['interfaces']['eth0']['ip'],
           director_address => $facts['networking']['interfaces']['eth0']['ip'],

           version => '20.0.0-1',
           
           console_password => '***REMOVED***',
      
           database_host => '127.0.0.1',
	   database_port => 3306,
	   database_user => 'root',
           database_password => 'turnkeyAvB12',
           database_name => 'bareos',
           database_backend => 'postgresql',
	   director_name => "${facts['hostname']}",
           default_jobdef => 'DefaultJob',
           noops => false,
     }

     # Creates a catalog...
     bareos::director::catalog {'MyCatalog':
		name => 'MyCatalog',
                db_user => 'bareos',
		db_name => 'bareos',
		db_password => 'turnkeyAvB12',
                db_driver => 'postgresql',
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

     # The File Daemon used to backup this director 
     # itself.
     include bareosdir::common::fdclient

     # Common Pools that show up in most 
     # bareos installations...Full, Differential, Incremental, Scratch
     include bareosdir::common::pools

     # Include the DefaultJob JobDef
     include bareosdir::common::jobdefs

     # Include generic filesets
     include bareosdir::common::fileset

     # Include all entries related to backing up the 
     # bareos-dir
     include bareosdir::common::baculadirectorfiles 

     # Include all entries related to backing up the
     # bareos-dir's Catalog
     include bareosdir::common::backupcatalog

     # Include the WeeklyCycle schedule
     include bareosdir::common::schedule



}
