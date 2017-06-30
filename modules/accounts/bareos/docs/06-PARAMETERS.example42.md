# == Example42 common paramters
#
#####################
# Define the general class behaviour and customizations
#####################
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, bareos class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $bareos_myclass
#
# [*source_dir*]
#   If defined, the whole bareos configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $bareos_source_dir
#
# [*source_director_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $bareos_source_director_purge
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $bareos_options
#
# [*service_autorestart*]
#   Automatically restarts the bareos service when there is a change in
#   configuration files. Default: true, Set to false if you don't want to
#   automatically restart the service.
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to true to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $bareos_absent
#
# [*disable*]
#   Set to true to disable service(s) managed by module
#   Can be defined also by the (top scope) variable $bareos_disable
#
# [*disableboot*]
#   Set to true to disable service(s) at boot, without checks if it's running
#   Use this when the service is managed by a tool like a cluster software
#   Can be defined also by the (top scope) variable $bareos_disableboot
#
# [*monitor*]
#   Set to true to enable monitoring of the services provided by the module
#   Can be defined also by the (top scope) variables $bareos_monitor
#   and $monitor
#
# [*monitor_tool*]
#   Define which monitor tools (ad defined in Example42 monitor module)
#   you want to use for bareos checks
#   Can be defined also by the (top scope) variables $bareos_monitor_tool
#   and $monitor_tool
#
# [*monitor_target*]
#   The Ip address or hostname to use as a target for monitoring tools.
#   Default is the fact $ipaddress
#   Can be defined also by the (top scope) variables $bareos_monitor_target
#   and $monitor_target
#
# [*puppi*]
#   Set to true to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $bareos_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $bareos_puppi_helper
#   and $puppi_helper
#
# [*firewall*]
#   Set to true to enable firewalling of the services provided by the module
#   Can be defined also by the (top scope) variables $bareos_firewall
#   and $firewall
#
# [*firewall_tool*]
#   Define which firewall tool(s) (ad defined in Example42 firewall module)
#   you want to use to open firewall for bareos port(s)
#   Can be defined also by the (top scope) variables $bareos_firewall_tool
#   and $firewall_tool
#
# [*firewall_src*]
#   Define which source ip/net allow for firewalling bareos. Default: 0.0.0.0/0
#   Can be defined also by the (top scope) variables $bareos_firewall_src
#   and $firewall_src
#
# [*firewall_dst*]
#   Define which destination ip to use for firewalling. Default: $ipaddress
#   Can be defined also by the (top scope) variables $bareos_firewall_dst
#   and $firewall_dst
#
# [*debug*]
#   Set to true to enable modules debugging
#   Can be defined also by the (top scope) variables $bareos_debug and $debug
#
# [*audit_only*]
#   Set to true if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $bareos_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# Default class params - As defined in bareos::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*service_status*]
#   If the bareos service init script supports status argument
#
# [*process_args*]
#   The name of bareos arguments. Used by puppi and monitor.
#
#   Used only in case the bareos process name is generic (java, ruby...)
#
# [*process_user*]
#   The name of the user bareos runs with. Used by puppi and monitor.
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*config_file_init*]
#   Path of configuration file sourced by init script
#
# [*data_dir*]
#   Path of application data directory. Used by puppi
#
# [*log_dir*]
#   Base logs directory. Used by puppi
#
# [*log_file*]
#   Log file(s). Used by puppi
#
# [*protocol*]
#   The protocol used by the the service.
#   This is used by monitor, firewall and puppi (optional) components
#   Can be defined also by the (top scope) variable $bareos_protocol
