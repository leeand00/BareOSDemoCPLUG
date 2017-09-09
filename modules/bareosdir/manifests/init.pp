class bareosdir {
 	# Setup the database if you need to...
	include bareosdir::dbinit
        include bareosdir::common


	# Define GFS19 Pools / Storage / Jobs for said backup clients...	
	bareosdir::jobconfig::backupclient {
		"webserver" : clientName => "webserver", clientIpOrHostname => 'webserver', includeBackupCopyJobs => true;
		#"bareOSremoteSD" : clientName => "bareOSremoteSD", clientIpOrHostname => 'bareOSremoteSD',  includeBackupCopyJobs => false;
	}

	# Define GFS19 Pools 

#      bareosdir::jobconfig::backupclient {"webserver":
#		clientName => "webserver",
#      }

}
