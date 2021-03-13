class bareosdir {

	notify {"bareosdir":
		message => "bareosdir",
	}


 	# Setup the database if you need to...
	include bareosdir::dbinit
        include bareosdir::common
        include bareosdir::lvmmountbks

#	# TODO: Load this from hiera
#	# Define GFS19 Pools / Storage / Jobs for said backup clients...	
	bareosdir::jobconfig::backupclient {
		"sshLandingBay" :  clientName => "sshLandingBay", 
			           clientIpOrHostname => '192.168.57.195', 
			           includeBackupCopyJobs => true,
			    	   jobPriority => '6',
				   copyjobPriority => '7',

##		"bareOSremoteSD" : clientName => "bareOSremoteSD", 
##				   clientIpOrHostname => 'bareOSremoteSD',  
##				   includeBackupCopyJobs => true,
##			    	   jobPriority => '8',
##				   copyjobPriority => '9'
	}

#      # Define GFS19 Pools 
#      bareosdir::jobconfig::backupclient {"sshLandingBay":
#		clientName => "sshLandingBay",
#      }

}
