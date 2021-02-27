class bareosdir::common::fdclient {

     # Client (File Services) to backup
     bareos::director::client {"${facts['hostname']}-fd":
	name => "${facts['hostname']}-fd",
     # NOTE: If run in Virtualbox it probably uses
     #       a different interface because of the way
     #       the networking is used.  In this case
     #       I am using a baremetal machine with only 
     #       one NIC, so I just use eth0.
     #    
     #       If using virtualbox you are welcome to swap it out
     #       with the below line:
     #
     #  address => $facts['networking']['interfaces']['eth2']['ip'],
        address => $facts['networking']['interfaces']['eth0']['ip'],
	catalog => 'MyCatalog',  # See `Creates a catalog...`
	file_retention => '6 months',  # Should be 6 months or so until you learn bacula better. 
	job_retention => '1 year',     # Should be equal to your maximum volume_retention (see the Monthly pool)
     }
}
