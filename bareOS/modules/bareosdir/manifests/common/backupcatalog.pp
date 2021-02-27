class bareosdir::common::backupcatalog {

     # Backup the catalog database (after the nightly save)
     bareos::director::job {'BackupCatalog':
        name => 'BackupCatalog',
        client => "${facts['hostname']}-fd",
	level => 'Full',
        fileset => 'Catalog',
	job_schedule => 'WeeklyCycle',
	

        # This creates an ASCII copy of the catalog
        # Arguments to make_catalog_backup.pl are:
        # make_catalog_backup.pl <catalog-name>
        client_run_before_job => '/usr/lib/bareos/scripts/make_catalog_backup.pl MyCatalog',
        
        # Somewhere in the tutorial he said to comment this out...so you can pick it up
        # later if something goes wrong.
        #client_run_after_job => '/usr/lib/bareos/scripts/delete_catalog_backup',

        #write_bootstrap => "|/usr/bin/bsmtp -h localhost -f \"\(Bareos\) \" -s \"Bootstrap for Job %j\" root@localhost",

	# THIS IS FOR DISASTER RECOVERY OF THE BACKUP SERVER!
	# This is from http://www.binarytides.com/linux-mail-command-examples/
	# "2. Subject and Message in a single line"   
#goodone write_bootstrap => "|/usr/bin/mail -s \\\"Bareos: Bootstrap file for Job ID:  %j\\\" 'helpdeskaleer@gmail.com' <<< 'helpdeskaleer@gmail.com",
 	write_bootstrap => "|/usr/bin/mail -s \\\"Bareos: Bootstrap file for Job ID:  %j\\\" 'helpdeskaleer@gmail.com' '<<<' 'helpdeskaleer@gmail.com'",


        # NOTE: They also say you should write out one of these with every job that you run, 
        #       to avoid running bscan on disaster recovery.
	# ALSO NOTE: If you wish to write it out to a file on a mounted smb share instead
	#            use the following line:
	#write_bootstrap => "/var/lib/bareos/%n.bsr", # This works, but it nly writes out a file...
       
  	# NOTE: This job MUST be run after all the other jobs have run.
     	#       This is accomplished by setting it to a priority number higher
        #       than the rest of the jobs.
        # run after main backup
	priority => '11',
     }


     # Fileset for backing up the bacula catalog:
     bareos::director::fileset{'Catalog':
	name => 'Catalog',

        # Pick up the database dump (see the BackupCatalog job for details. 
        include => ['/var/lib/bareos/bareos.sql'],
     }

}
