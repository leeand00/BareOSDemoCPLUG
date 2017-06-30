node 'bareOSdirector' {

     class {'bareos':
           manage_client => true,
           manage_storage => true,
           manage_director => true,
           manage_console => true,
           version => '16.2.4-12.1',
           database_host => '127.0.0.1',
	   database_port => 3306,
	   database_user => 'root',
           database_password => 'turnkeyAvB12',
           database_backend => 'mysql',
	   director_template => 'bareos/bareos-dir.conf.erb',
           storage_template => 'bareos/bareos-sd.conf.erb',
           noops => false, 
     }

     file {'/tmp/bareOSdir.txt':
           content => "bareos\n",
           owner => root,
           mode  => 775,
     }
}

node 'webserver' {

    class{'bareos':
           manage_client => true,
           manage_storage => false,
           manage_director => false,
           manage_console => false,
           version => '16.2.4-12.1',
           noops => false,
    }

    file {'/tmp/nginx.txt':
          content => "nginx\n",
          owner => root,
          mode => 775,
    }
}

node default {
    notify {'Default Node':

    }
}
