# Purpose:
# Takes care of setting up directorys for mounting
# LVM devices for doing backups.
class bareosdir::lvmmountbks {

    notify {'blah':
        message => 'blah blah blah',
    }    

    mount { '/mnt/backups/sshLandingBay': 
	ensure => 'mounted',
	device => '/dev/Backups/sshLandingBay_Backup',
	fstype => 'ext4',
	options => 'defaults',
    }

}
