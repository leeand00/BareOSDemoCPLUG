# Define bareos::storage::device
#
# Used to create an autochanger in a storage manager
#
define bareos::storage::autochanger (
  $name = '',
  $device = '',
  $changer_command = '',
  $changer_device = '',
  $source = '',
  $options_hash = {},
  $template = 'bareos/storage/autochanger.conf.erb',
) {
  
  include bareos

  $manage_storage_service_autorestart = $bareos::service_autorestart ? {
    true => Service[$bareos::storage_service],
    default => undef,
  }

  # TODO: Get rid of this if you don't need it...
  #$real_archive_device = $archive_device ? {
  #  ''      => $bareos::default_archive_device,
  #  default => $archive_device,
  #}

  #if $real_archive_device == '' {
  #  fail('$archive_device parameter required for bareos::storage::device define')
  #}}

  $manage_autochanger_content = $template ? {
    '' => undef,
    default => template($template),
  }

  $manage_autochanger_source = $source ? {
    '' => undef,
    default => $source,
  }

 

  file {"autochanger-${name}.conf":
    ensure    => $bareos::managefile,
    path      => "${bareos::storage_configs_dir}/autochanger-${name}.conf",
    mode      => $bareos::config_file_mode,
    owner     => $bareos::config_file_owner,
    group     => $bareos::config_file_group,
#    require   => Package[$bareos::storage_package],
    notify    => $manage_storage_service_autorestart,
    content   => $manage_autochanger_content,
    source    => $manage_autochanger_source,
    replace   => $bareos::manage_file_replace,
    audit     => $bareos::manage_audit,
  }
}
