# Creates a postfix config file beyond $postfix::config_dir and
# does a postalias on this. (Wrapper for postfix::config)
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
# - file_type: which database type to use (default: undef ... see
#              postalias(1))
#
# - service_autorestart: if to notify the service afterwards
#                        (default: see postfix class)
#
# Exactly one of +content+, +source+ and +template+ has to be set!
#
define postfix::alias(
  $content             = undef,
  $source              = undef,
  $template            = undef,
  $options             = undef,
  $file_type           = undef,
  $service_autorestart = undef
) {
  postfix::config { $name:
    content             => $content,
    source              => $source,
    template            => $template,
    post_cmd            => 'postalias',
    file_type           => $file_type,
    service_autorestart => $service_autorestart,
  }
}

