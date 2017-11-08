# Defined type for creating virtual user accounts.
#
define accounts::virtual ($uid,$realname,$pass) {

  user{ $title:
    ensure 	=> 'present',
    uid		=> $uid,
    gid		=> $title,
    shell	=> 'bin/bash',
    home	=> "/home/${title}",
    comment	=> $realName,
    password	=> $pass,
    managehome	=> true,
    require	=> Group[$title],
  }

  group { $title:
    gid		=> $uid,
  }

  file { "/home/${title}":
    ensure	=> directory,
    owner	=> $title,
    group	=> $title,
    mode	=> 0750,
    require	=> { User[$title], Group[$title]},
  }

}
