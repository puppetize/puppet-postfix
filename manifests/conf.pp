# Changes/sets a config option in the main.cf config file.
#
# == Parameters
#
# - name:  name of the parameter
# - value: value the `name' should be set to
#
# - service_autorestart: if to notify the service afterwards
#                        (default: see postfix class)
#
define postfix::conf(
  $value,
  $service_autorestart = undef
) {
  include postfix

  # if the main.cf is completely managed by puppet
  # this stuff will clash
  if $postfix::content or $postfix::source or $postfix::template {
    fail('postfix::conf cannot being used if the main.cf is managed by puppet')
  }

  $notify_service = $service_autorestart ? {
    undef   => $postfix::service_autorestart,
    default => $service_autorestart,
  }

  validate_bool($notify_service)

  exec { "postconf ${name}":
    command => "postconf -e '${name}'='${value}'",
    unless  => "test X\"`postconf -h '${name}'`\" = X'${value}'",
    path    => '/usr/sbin:/usr/bin:/bin',
  }

  if $notify_service {
    Exec["postconf ${name}"] ~> Service[$postfix::service]
  }

  Package[$postfix::package] -> Exec["postconf ${name}"]
}
