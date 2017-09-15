define bareossd::autochangerndevices($configName) {

	$GFS = hiera('gfs19')
	$config = hiera($configName)

	$hashDefaults = {
		value => 'zzz'
	}


	#create_resources(hashdebug, $config, $hashDefaults)

	# get the keys from the ... hash...
	#$configKeys = keys($config)
	#$autochangerBasePath = $configKeys['autochangerBasePath']	
	#$autochangerDevices = keys($configKeys['autochangerDevices'])	
	
	

    	# Generates directories for storage of volumes
    	#file {"${$autochangerBasePath}":
	#   ensure => 'directory',
	#   owner => bareos,
	#   group => bareos,
	#   mode => 660,
	#}

	

}
