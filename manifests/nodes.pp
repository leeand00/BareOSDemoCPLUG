node 'bareOSdirector' {

     # Allow email to be sent from this bareOSdirector
     # to my gmail account.
     include postfix

     # Include the setup of the bareos-dir,
     # - This includes the database setup...
     include bareosdir 


#     exec {'Setting Time':
#		command => 'sudo date -s \"1 JAN 2017 01:00:00\"',
#		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin',
#		cwd	=> '/home/vagrant',
#		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
#     }

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


        file { [  '/mnt/backups', "/mnt/backup", "/mnt/backup2", "/mnt/backup3", "/mnt/backup4" ]:
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
