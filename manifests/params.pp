# all variables can be overwritten with hiera (Puppet >= 3)
# through the `postfix' class
class postfix::params {
  case $::osfamily {
    'Debian': {
      $config_dir = '/etc/postfix'
      $package    = 'postfix'
      $service    = 'postfix'
    }
    default: {}
  }

  $service_autorestart = true
}
