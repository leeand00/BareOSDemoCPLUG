# Used to define/realize users on Puppet-managed systems
#
class accounts {

  @accounts::virtual{ 'bareos':
    uid		=> 1001,
    realname	=> "bareos user",
    pass	=> "***REMOVED***"
  }

}
