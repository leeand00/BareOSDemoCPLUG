class bareossd {

# bareOSremoteSD_AutoChangerBasePath

	# Create devices for auto changer
	#bareossd::autochangerNdevices{"what":
	#  configName => "bareOSremoteSD_DevConfig",
	#}

	bareossd::hashdebug {
		"webserver": clientName => "webserver";
	}
}
