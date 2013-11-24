# Manage the Postfix Mail Transport Agent.
#
# The main.cf config file can be managed in different ways:
#
#   1. it will be fully managed if one of `content', `source',
#      `template' is used, postfix::conf is then failing if
#      it is used somewhere else
#   2. the default main.cf provided by the package provider is
#      left in place and it can be changed with the `options'
#      parameter or through postfix::conf
#
# == Parameters
#
# - content:  content for the main.cf (default: `undef')
# - source:   source for the main.cf (default: `undef')
# - template: template for the main.cf (default: `undef')
# - options:  if `content', `source' or `template' is defined
#             it is ignored (but it can be used within the
#             `template') otherwise it has to be a Hash of valid
#             postconf(5) key/value pairs
#
# == Parameters with defaults from postfix::params
# - config_dir:          configuration directory for postfix
# - package:             name of the package to install
# - service:             name of the service
# - service_autorestart: if a config change triggers a reload
#
# == Example:
#
#   class { 'postfix':
#     options => {
#       'message_size_limit' => '10240000'
#     }
#   }
class postfix(
  $content             = undef,
  $source              = undef,
  $template            = undef,
  $options             = undef,

  $config_dir          = $postfix::params::config_dir,
  $package             = $postfix::params::package,
  $service             = $postfix::params::service,
  $service_autorestart = $postfix::params::service_autorestart,
) inherits postfix::params {

  validate_string($config_dir)
  validate_string($package)
  validate_string($service)
  validate_bool($service_autorestart)

  if empty($config_dir) or empty($package) or empty($service) {
    fail('none of `config_dir\', `package\', `service\' can be empty')
  }

  if $content and $source or $source and $template or $content and $template {
    fail('only one of +content+, +source+ and +template+ can be set')
  }

  $notify_service = $service_autorestart ? {
    true    => Service[$service],
    default => undef,
  }

  package { $package:
    ensure => present,
  }

  service { $service:
    ensure => running,
    enable => true,
  }

  if $content or $source or $template {
    $config_options = {}

    if $content {
      $config_options['content'] = $content
    } elsif $source {
      $config_options['source'] = $source
    } else {
      $config_options['content'] = template($template)
    }

    $filename = "${config_dir}/main.cf"

    file { $filename:
      ensure  => file,
      source  => $config_options['source'],
      content => $config_options['content'],
      mode    => '0644',
      owner   => 'root',
      require => Package[$package],
    }

    if $notify_service {
      File[$filename] ~> Service[$service]
    }
  } elsif $options {
    validate_hash($options)

    postfix_conf($options)
  }

  Package[$package] -> Service[$service]
}
