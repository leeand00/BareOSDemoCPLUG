class postfix::install {
	package {'postfix':
		ensure => installed,
 	}

	package {'libsasl2-modules':
		ensure => installed,
	}
	
	service {'postfix':
	 	ensure => running,
		enable => true,
		require => [Package['postfix'], Package['libsasl2-modules']]
	}
}
