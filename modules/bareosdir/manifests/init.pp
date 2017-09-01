class bareosdir {
 	# Setup the database if you need to...
	include bareosdir::dbinit
        include bareosdir::common


	# Define GFS19 Pools / Storage / Jobs for said backup clients...	
	bareosdir::jobconfig::backupclient {
		"webserver" : clientName => "webserver", clientIpOrHostname => 'webserver';
		#"bareOSremoteSD" : clientName => "bareOSremoteSD", clientIpOrHostname => 'bareOSremoteSD';
	}

#      bareosdir::jobconfig::backupclient {"webserver":
#		clientName => "webserver",
#      }

}
