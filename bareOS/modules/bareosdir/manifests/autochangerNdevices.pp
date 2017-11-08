define bareosdir::autochangerNdevices($configName) {

	$GFS = hiera('gfs19')
	$config = hiera($configName)
	
	# get the keys from the ... hash...
	$configKeys = keys($configName)
	$autochangerBasePath = $configKeys['autochangerBasePath']	
	$autochangerDevices = keys($configKeys['autochangerDevices'])	
	

	#notify{"${configName}-oppw2":
	#	message => "${configName}: ${autochangerBasePath}, ${autochangerDevices}",
	#}

    	# Generates directories for storage of volumes
    	#file {"${$autochangerBasePath}":
	#   ensure => 'directory',
	#   owner => bareos,
	#   group => bareos,
	#   mode => 660,
	#}

	

}
