define bareossd::clientautochangerndevices_manager($clientsHash, $basePath) {

	$clientHashKeys = keys($clientsHash)

	# Create the directory for the archive...
	file {"$basePath":
	     ensure => 'directory',
	     owner => bareos,
	     group => bareos,
	     mode => 660,
	}
	
	#notify {$clientHashKeys: 
	#	message => $clientsHash['clientName'], 
	#}

	bareossd::clientautochangerndevices {$clientHashKeys:
		clientsHash => $clientsHash,
		basePath => $basePath,
	}	
}
