define bareossd::clientautochangerndevices($clientsHash, $basePath) {
	
	# Note: https://forge.puppet.com/puppetlabs/stdlib#prefix
	#$result = prefix($value, $autochangerName)


	$whichClient = $clientsHash[$name]
	$clientName = $whichClient['clientName']

	notify {"${whichClient}-zyx": message => $clientName, }

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
	file {"${basePath}/${clientName}":
	     ensure => 'directory',
	     owner => vagrant,
	     group => bareos,
	     mode => 660,
	     require => File["${basePath}"],
	}


	bareossd::autochangerdevices{$gfsKeys:
	   clientName => "${clientName}",
	   backupBasePath => "${basePath}",
	   gfsHash => $GFS,
	   require => File["${basePath}"],
	}
}
