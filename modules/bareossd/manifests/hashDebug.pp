define bareossd::hashDebug($value, $othervalue, $somevalue) {

	notify { "Item ${name} has value ${value}, othervalue ${othervalue}, somevalue ${somevalue}" }

#	notify{"${configName}-oppw2":
#		#message => "${configName}: ${autochangerBasePath}, ${autochangerDevices}",
#		 message => "${configName}: ${autochangerBasePath}",
#
#	}
}
