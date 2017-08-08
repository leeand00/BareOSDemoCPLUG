class bareosdir::common::fdclient {

     # Client (File Services) to backup
     bareos::director::client {"${hostname}-fd":
	name => "${hostname}-fd",
        address => $ipaddress_eth0,
	catalog => 'MyCatalog',  # See `Creates a catalog...`
	file_retention => '6 months',  # Should be 6 months or so until you learn bacula better. 
	job_retention => '1 year',     # Should be equal to your maximum volume_retention (see the Monthly pool)
     }
}
