class bareosdir::common::schedule {
     # Schedule
     bareos::director::schedule{'WeeklyCycle':
       name => 'WeeklyCycle',
       
        run_spec => [['Differential', 'Pool=Daily monday-thursday', '22:10'], # 8pm
                     ['Full', 'Pool=Weekly 2nd-5th fri', '22:10'], 
                     ['Full', 'Pool=Monthly 1st fri', '22:10']],

	# Schedule for off site backups...(where the backup is stored offsite)
       #run_spec => [
        #            ['Differential', 'Pool=Offsite-Daily monday-thursday', '23:30'], # 11pm (sons)
        #            ['Full', 'Pool=Offsite-Weekly 2nd-5th Friday', '23:30'], # 11pm (fathers)  
								     # Note: 2nd - 5th Friday because some months have 5 fridays in them.
        #            ['Full', 'Pool=Offsite-Monthly 1st Friday', '23:30'],  # First Friday of the month Montly backup is done.
								 # 11pm (grandfathers)
        #           ], 
     }

    bareos::director::schedule{'WeeklyCycleCopy':
	name => 'WeeklyCycleCopy',

	run_spec => [
		['Full', 'Pool=Daily NextPool=DailyCopyPool monday-thursday', '22:15'],
		['Full', 'Pool=Weekly NextPool=WeeklyCopyPool 2nd-5th fri', '22:15'],
		['Full', 'Pool=Monthly NextPool=MonthlyCopyPool 1st fri', '22:15'],
	]
    } 
}
