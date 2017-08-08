class bareosdir::common::jobdefs {

     # Define the main nightly save backup job
     bareos::director::job {'DefaultJob':
        name => 'DefaultJob',
	use_as_def => 'true', # Makes this a JobDef using the job template :p damn you!
	type => 'Backup',
	level => 'Incremental',
	fileset => 'SelfTest', # Forces you to remeber that you need to define a fileset in your job.
        job_schedule => 'WeeklyCycle',
        # Note: I removed storage from the Default JobDef because it confuses people.
	#storage => "${hostname}_FileStorage",
	messages => 'standard',
	pool => 'Daily',
	priority => '10',
	write_bootstrap => '/var/lib/bareos/%c.bsr',
# TODO: WHAT THE HELL?!?!#?
	full_backup_pool => 'Full',
	diff_backup_pool => 'Differential',
        inc_backup_pool => 'Incremental',
     }
}
