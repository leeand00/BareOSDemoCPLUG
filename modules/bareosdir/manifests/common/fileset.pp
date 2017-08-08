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


     # Fileset for self testing
     bareos::director::fileset{'SelfTest':
	name => 'SelfTest',
        include => ['/usr/sbin'],
     }

     # TODO: Add a Windows FileSet
}
