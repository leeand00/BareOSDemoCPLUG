#node 'bareosdir.helpdeskaleer.com' {
#   notify {'Processing BareOS Dir':
#
#   }
#
#   include 'bareosdir'
#}

node 'bareosdir' {
   class { bareosdir: }

   notify {'bareosdir iz processing':

   }

}

node default {
   notify {'Default Node':

   }
}
