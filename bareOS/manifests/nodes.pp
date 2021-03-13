#node 'bareOSdirector' {
#
#     # Allow email to be sent from this bareOSdirector
#     # to my gmail account.
#     include postfix
#
#     # Include the setup of the bareos-dir,
#     # - This includes the database setup...
#     include bareosdir 
#
#     # NOTE! I disabled this so I can test out the configuration of the copy jobs${clientName}-${whichGFS}-volnum-${NumVols}.
#     # 
#     # Automatically set the time back to 30 DEC 2016 21:30:00...so that we have a fresh point to
#     # test the backups with...you may want to comment this out after setup.
#     exec {'Setting Time':
#         	command => 'sudo date -s "30 DEC 2016 21:30:00"',
#     		path    => '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin',
#     		cwd	=> '/home/vagrant',
#     		#returns => [0, 1], # https://serverfault.com/questions/450602/puppet-error-returned-1-instead-of-one-of-0
#     }
#
## We must stop this service so that
## we can set the date when testing 
## backup configuarions.
##
## Note: you may also be required to run "VBoxManage setextradata "VM name" "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" 1"
## to keep the date from being set
##
## Note: If it becomes evident that you need this vboxadd-service,
##       you can do this to disable the timesync with the host:
##       https://stackoverflow.com/a/38657239  
##        
##     service {'vboxadd-service':
##	ensure => 'stopped',
##     }
#
#}

#node 'bareOSremoteSD' {
#
#        # Include the setup of the bareos-dir,
#        # - This includes the database setup...
#        #include bareossd
#
#	# bls and bextract for restoring from a dead director...
#	package {'bareos-tools':
#		ensure => installed,
# 	}
#
#	class {'bareos':
#	      manage_client => true,
#	      manage_storage => true,
#	      manage_director => false,
#	      manage_console => false,
#	      manage_database => false,
#	      default_password => '***REMOVED***',
#	      storage_template => 'bareos/bareos-sd.conf.erb',
#	      client_template => 'bareos/bareos-fd.conf.erb',
#	      client_address => $ipaddress_eth2,
#	      version => '16.2.4-12.1',
#	      noops => false,
#
#	      # Configure the off-site storage daemon
#	      storage_name => "${hostname}",
#	      storage_address => $ipaddress_eth2,
#	      storage_max_concurrent => 20,
#	      director_name => 'bareOSdirector',  # TODO: Find a way to get this directly form the node above.
#	      storage_password => "storage_password",
#	}
#
#
#	include bareossd
##
##        bareos::storage::autochanger {'FileChgr1': 
##	      name => 'FileChgr1',
##              device => 'FileChgr1-Dev1, FileChgr1-Dev2, FileChgr1-Dev3',
##  	      changer_command => '',
##	      changer_device => '/dev/null',
##	}
##
##	bareos::storage::device {'FileChgr1-Dev1':
##	      name => 'FileChgr1-Dev1',
##	      media_type => 'File1',
##	      archive_device => '/mnt/backup/bareOSdirector',
##	      label_media => 'yes',
##              random_access => 'yes',
## 	      automatic_mount => 'yes',
##	}
##
##	bareos::storage::device {'FileChgr1-Dev2':
##	      name => 'FileChgr1-Dev2',
##	      media_type => 'File1',
##	      archive_device => '/mnt/backup/webserver',
##	      label_media => 'yes',
##              random_access => 'yes',
## 	      automatic_mount => 'yes',
##	}
##
##	bareos::storage::device {'FileChgr1-Dev3':
##	      name => 'FileChgr1-Dev3',
##	      media_type => 'File1',
##	      archive_device => '/mnt/backup/bareOSremoteSD',
##	      label_media => 'yes',
##              random_access => 'yes',
## 	      automatic_mount => 'yes',
##	}
##
##
##	file {'/etc/bareos/storage.d/FileChgr1.conf':
##	     ensure => 'absent',
##	     content => file("bareos/FileChgr1"),
##	     owner => bareos,
## 	     group => bareos,
##             mode => 660,
##	}
##
##
##        file { [  '/mnt/backups', "/mnt/backup", "/mnt/backup/bareOSdirector", "/mnt/backup/webserver", "/mnt/backup/webserver/monthly", "/mnt/backup/webserver/weekly", "/mnt/backup/webserver/daily", "/mnt/backup/bareOSremoteSD", "/mnt/backup3", "/mnt/backup4" ]:
##     	     ensure => 'directory',
##             owner => bareos,
##             group => bareos,
##             mode  => 660,
##        }
#
#}

#node 'webserver' {
#    
#    class{'bareos':
#           manage_client => true,
#           manage_storage => false,
#           manage_director => false,
#           manage_console => false,
#           version => '16.2.4-12.1',
#           noops => false,
#
#	   director_name => 'bareOSdirector',  # TODO: Find a way to get this directly form the node above.
#	   default_password => '***REMOVED***',
#	   client_template => 'bareos/bareos-fd.conf.erb',
#           client_address => $ipaddress_eth2,
#
#    }
#
#    # Create a file for generating a bunch of random file content
#    # for us to back up.
#    file {'/home/vagrant/random.sh':
#        content => file('bareos/random.sh'),
#        owner => vagrant,
#        mode => 775,
#    }
#
#
#    file {'/tmp/nginx.txt':
#          content => "nginx\n",
#          owner => root,
#          mode => 775,
#    }
#
#     # Stops syncing the clock of the guest to the host
#     #service {'vboxadd-service':
#     #	ensure => 'stopped',
#     #}
#
##   $clientBackupPath = "/mnt/backups/${clientName}" 
##
#   $GFS = {
#	'g' => 'monthly',
#	'f' => 'weekly',
#	's' => 'daily', 	
#   }
##
##   $GFSarr = ["${clientBackupPath}/daily","${clientBackupPath}/weekly","${clientBackupPath}/monthly"]
#
#   $b = ['a','b','c']
#
#    $k = keys($GFS)
#
#    notify {$k:
#	message => $name,
#    }
#
##    $gitHubUsername = hiera("github_username")
##    $gitHubEmail = hiera("github_email")
##    $dasTest1 = hiera("test_1")
##    $w = keys($dasTest1)
##
##    notify{"test":
##      message => "Username: ${gitHubUsername}, Email: ${gitHubEmail}, test: ${w}",
##    }
#
#
##     class {'testme':
##
##     }
#
##   $b.each |Integer $index, String $value| { notice("${index} = ${value}") }
#}


#node 'bareosdir.helpdeskaleer.com' {
#    notify {'Bare OS Dir':
#
#    }
#}

#node default {
#    notify {'Default Node':
#
#    }
#}
