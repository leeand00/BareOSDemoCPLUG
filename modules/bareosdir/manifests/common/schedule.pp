class bareosdir::common::schedule {
     # Schedule
     bareos::director::schedule{'WeeklyCycle':
       name => 'WeeklyCycle',
       
#       run_spec => [['Differential', 'Pool = Daily', 'monday-thursday', '20:00'], # 8pm
#                    ['Differential', '2nd-5th sat', '23:05'], 
#                    ['Incremental', 'mon-fri', '23:05']],

       run_spec => [
                    ['Differential', 'Pool=Offsite-Daily monday-thursday', '23:30'], # 11pm (sons)
                    ['Full', 'Pool=Offsite-Weekly Friday', '23:30'], # 11pm (fathers)  
								     # Note: 2nd - 5th Friday because some months have 5 fridays in them.
                    ['Full', 'Pool=Offsite-Monthly 1st Friday', '23:30'] # First Friday of the month Montly backup is done.
								 # 11pm (grandfathers)

                   ], 
     } 
}
