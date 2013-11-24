# Creates a postfix config file beyond $postfix::config_dir and
# notifies the service if wanted.
# It can also use postmap(1) or postalias(1) to create the necessary
# db.
#
# == Parameters:
#
# - name:      name of the file which will be created
# - content:   the content of the file (default: undef)
# - source:    the source of the file (default: undef)
# - template:  a template to evaluate and to use as content
#              (default: undef)
# - options:   this is ignored but can be used to pass variables
#              through and use them inside a custom template
#
# - post_cmd:  if the file is a database which has to be processed
#              through postalias(1) or postmap(1) then this can be
#              set to `postalias' or `postmap'
# - file_type: which database type to use (default: undef ... see
#              postalias(1) and postmap(1))
#
# - service_autorestart: if to notify the service afterwards
#                        (default: see postfix class)
#
# Exactly one of +content+, +source+ and +template+ has to be set!
#
define postfix::config(
  $content             = undef,
  $source              = undef,
  $template            = undef,
  $options             = undef,
  $post_cmd            = undef,
  $file_type           = undef,
  $service_autorestart = undef
) {
  include postfix

  if $content and $source or $source and $template or $content and $template {
    fail('only one of +content+, +source+ and +template+ can be set')
  }

  if !$content and !$source and !$template {
    fail('one of +content+, +source+ or +template+ has to be defined')
  }

  # check for valid post_cmd and file_type
  if $post_cmd != undef {
    validate_string($post_cmd)

    if !($post_cmd in ['postmap', 'postalias']) {
      fail('post_cmd only supports +postmap+ and +postalias+')
    }
  }

  if $post_cmd == undef and $file_type != undef {
    fail('no +post_cmd+ was set but +file_type+ is specified')
  }

  if $file_type != undef {
    validate_string($file_type)

    if empty($file_type) {
      fail('empty string as +file_type+ is not possible')
    }
  }

  $notify_service = $service_autorestart ? {
    undef   => $postfix::service_autorestart,
    default => $service_autorestart,
  }

  validate_bool($notify_service)

  $filename = "${postfix::config_dir}/${name}"

  file { $filename:
    ensure  => file,
    owner   => 'root',
    mode    => '0640',
    require => Package[$postfix::package],
  }

  if $content {
    $content_real = $content
  } elsif $template {
    $content_real = template($template)
  } else {
    $content_real = false
  }

  if $content_real {
    File[$filename] {
      content => $content_real
    }
  } else {
    File[$filename] {
      source => $source
    }
  }

  if $post_cmd {
    $file_type_real = $file_type ? {
      undef   => '',
      default => "${file_type}:",
    }
    $post_cmd_real = "${post_cmd} ${file_type_real}${filename}"

    exec { $post_cmd_real:
      command     => $post_cmd_real,
      refreshonly => true,
      path        => '/usr/sbin:/sbin',
      subscribe   => File[$filename],
      require     => Package[$postfix::package]
    }

    if $notify_service {
      Exec[$post_cmd_real] ~> Service[$postfix::service]
    }
  } elsif $notify_service {
    File[$filename] ~> Service[$postfix::service]
  }
}

