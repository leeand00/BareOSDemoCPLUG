class postfix::config {

	$username='helpdeskaleer'
	$email_domain='gmail.com'
	$email_host='smtp.gmail.com'
	$email_host_port='587'
	$src_hostname='bareOSdirector'
	$auth_passwd='Log***REMOVED***'

	file {'/etc/postfix/sasl_passwd':
		ensure => present,
		content => template('postfix/sasl_passwd.erb'),
		notify => [Exec["re-postmapping sasl_passwd"],Service["postfix"]],
 	}

	file {'/etc/postfix/main.cf':
		ensure => present,
		content => template('postfix/main.cf.erb'),
		notify => [Service["postfix"]],
		require => [File["/etc/postfix/sasl_passwd"]],
 	}

	exec {'re-postmapping sasl_passwd':
		command => 'sudo postmap /etc/postfix/sasl_passwd',
		path	=> '/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin',	
		cwd 	=> '/tmp',
		
	}

}
