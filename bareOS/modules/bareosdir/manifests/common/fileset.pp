class bareosdir::common::fileset {

     # Generic file sets
     # One for Linux
     bareos::director::fileset{'LinuxAll':
	name => 'LinuxAll',
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'], 
        include => ['/'],

        # Things that usually have to be excluded
	# You have to exclude /var/lib/bareos/storage on your bareos server

        # TODO: Add /mnt/Backups if it's a mount you're adding with lvm:
        exclude => ['/var/lib/bareos', '/var/lib/bareos/storage', '/proc', '/tmp', '.journal', '.fsck'],
     } 

    bareos::director::fileset{'sshLandingBay-fs':
	
	
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'], 
        include => ['/etc', '/home'],

        exclude => ['/var/lib/bareos', '/var/lib/bareos/storage', '/proc', '/tmp', '.journal', '.fsck'],
    }

    bareos::director::fileset{'bareOSremoteSD-fs':
	
	
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'], 
        include => ['/etc', '/home'],

	# TODO: Add /mnt/backups as a variable from somewhere else
        exclude => ['/var/lib/bareos', '/var/lib/bareos/storage', '/mnt/backups', '/proc', '/tmp', '.journal', '.fsck'],
    }

    bareos::director::fileset{'bareOSdirector-fs':
	
	fstype => ['ext2', 'ext3', 'ext4', 'xfs', 'zfs', 'reiserfs', 'jfs', 'btrfs'], 
        include => ['/etc', '/home'],

        exclude => ['/var/lib/bareos', '/var/lib/bareos/storage', '/mnt/backups', '/proc', '/tmp', '.journal', '.fsck'],

    }

     # Empty fileset for Backup Copy Jobs...
     bareos::director::fileset{'EmptyCopyToTape':
	name => 'EmptyCopyToTape',
     }

     # Fileset for self testing
     bareos::director::fileset{'SelfTest':
	name => 'SelfTest',
        include => ['/usr/sbin'],
     }

     # TODO: Add a Windows FileSet
}
