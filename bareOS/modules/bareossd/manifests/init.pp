class bareossd {

# bareOSremoteSD_AutoChangerBasePath

	# Create devices for auto changer
	#bareossd::autochangerNdevices{"what":
	#  configName => "bareOSremoteSD_DevConfig",
	#}

	# TODO: Replcae this with heira
	$clients = {
		    "webserver" => {
			clientName => "webserver",
		    },
		    "bareOSremoteSD" => {
			clientName => "bareOSremoteSD",
		    },
	}

	# TODO: Add this in this way until 
	# we iron out how to get rid of the 
	# fd on the director...
	$clients['bareOSdirector'] = {
			clientName => "bareOSdirector",
	}

	# Class that manages devices and directory creation	
	bareossd::clientautochangerndevices_manager {"backupManager":
		clientsHash => $clients,
		basePath => "/mnt/backups", # Where to put the client backups
	}

}
