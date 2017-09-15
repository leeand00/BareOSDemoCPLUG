define bareossd::hashdebug($clientName) {


	# Note: https://forge.puppet.com/puppetlabs/stdlib#prefix
	#$result = prefix($value, $autochangerName)

	notify {"${name}": message => $clientName, }


	$GFS = {
		"s${clientName}" => {
		   name => "daily",
		   media_type => "File4",
		   archive_device => "",
		   label_media => "yes",
		   random_access => "yes",
		   automatic_mount => "yes",
		},
		"g${clientName}" => {
		   name => "monthly",
		   media_type => "File4",
		   archive_device => "",
		   label_media => "yes",
		   random_access => "yes",
		   automatic_mount => 'yes',
		},
		"f${clientName}" => {
		   name => "weekly",
		   media_type => "File4",
		   archive_device => "",
		   label_media => "yes",
		   random_access => "yes",
		   automatic_mount => "yes",
		}
	}

	$gfsKeys = keys($GFS)

	# Create a directory for this clients backups..
	file {"/mnt/backups/${clientName}":
	     ensure => 'directory',
	     owner => bareos,
	     group => bareos,
	     mode => 660,
	     require => File["/mnt/backups"],
	}

	# Create the directory for the archive...
	file {"/mnt/backups":
	     ensure => 'directory',
	     owner => bareos,
	     group => bareos,
	     mode => 660,
	}

	bareossd::autochangerdevices{$gfsKeys:
	   clientName => "${clientName}",
	   backupBasePath => "/mnt/backups",
	   gfsHash => $GFS,
	   require => File["/mnt/backups"],
	}

#	bareos::storage::device {$result:
#	      media_type => 'File1',
#	      archive_device => "/mnt/backup/${name}/${result}",
#	      label_media => 'yes',
#              random_access => 'yes',
# 	      automatic_mount => 'yes',
#	}
	
	#create_resources(bareossd::autochangerdevices, $result)

	

#	notify{"${configName}-oppw2":
#		#message => "${configName}: ${autochangerBasePath}, ${autochangerDevices}",
#		 message => "${configName}: ${autochangerBasePath}",
#
#	}
}
