define bareossd::autochangerdevices($clientName, $backupBasePath, $gfsHash) {

	$archivePath = "${backupBasePath}/$clientName"

	# Obtain the GFS object from the hash	
	$whichGFSObj = $gfsHash[$name]

	# Create the name of the autochanger...
	$autochangerName = "FileChgr-File-${clientName}-${whichGFSObj['name']}-CopyPool"

	notify{"${name}-nfy":
	  message => "${archivePath}/${whichGFSObj['name']}"
	}

	# Define the autochanger for this client
	# on the bareossd
        bareos::storage::autochanger {$autochangerName: 
	      name => $autochangerName,
	      #TODO: Add multiple devices for each...I guess...
	      device => "${autochangerName}-Dev1",
#              device => join($value, ", "),
  	      changer_command => '',
	      changer_device => '/dev/null',
	}


	
	# Create the directory for the archive...
	file {"${archivePath}/${whichGFSObj['name']}":
	     ensure => 'directory',
	     owner => bareos,
	     group => bareos,
	     mode => 660,
	     require => File["${archivePath}"],
	}

	# Create the device to manage the archive
	bareos::storage::device {"${autochangerName}-Dev1":
	     name => "${autochangerName}-Dev1", 
	     media_type => $whichGFSObj['media_type'],
	     archive_device => "${archivePath}/${whichGFSObj['name']}",
	     label_media => $whichGFSObj['label_media'],
	     random_access => $whichGFSObj['random_access'],
	     automatic_mount => $whichGFSObj['automatic_mount'],
	     require => File["${archivePath}/${whichGFSObj['name']}"],
	}

}
