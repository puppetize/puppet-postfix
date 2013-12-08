# Creates/changes a master.cf entry (postfix service)
#
# This uses augeas! So ensure that it is installed on
# your system and has all necessary lenses.
#
# In the next versions of postfix the postconf command
# will also enable us to change the master.cf .. so this
# doesn't need to use augeas in the future (TODO check
# what is better or if both should be possible)
#
# == Parameters (see master(5) for all of them):
#
# - name:         service name | type (one of `inet', `unix', `fifo', `pass')
#                 this is a combination of the name and the type to ensure the
#                 uniqueness of it and to enable multiple services with the same
#                 name but different types
#                 Example: smtp|unix
# - private:      one of `y', `n', `-'
# - unprivileged: one of `y', `n', `-'
# - chroot:       one of `y', `n', `-'
# - wakeup:       number or `-',
# - limit:        number or `-',
# - command:      command as string
# - command_args: command arguments as string or array with multiple
#                 arguments (default: undef)

# - service_autorestart: if to notify the service afterwards
#                        (default: see postfix class)
#
## only if defaults are not sufficient you can override some parameters
## of the augeas resource (see augeas resource documentation)
# - lens:      lens name to use (default: Postfix_Master.lns)
# - load_path: directories which should be searched for lenses
#              (default: undef)
define postfix::master(
  $private,
  $unprivileged,
  $chroot,
  $wakeup,
  $limit,
  $command,
  $command_args = undef,
  $service_autorestart = undef,

  $lens = 'Postfix_Master.lns',
  $load_path = undef,
) {
  include postfix

  validate_re($name, '^[^|]+\|(inet|unix|fifo|pass)$')

  $service_name = regsubst($name, '^([^|]+).*', '\1')
  $type = regsubst($name, '.*\|(.+)$', '\1')

  if !($private in ['y', 'n', '-']) {
    fail('`private\' can only be one of +y+, +n+, +-+')
  }

  if !($unprivileged in ['y', 'n', '-']) {
    fail('`unprivileged\' can only be one of +y+, +n+, +-+')
  }

  if !($chroot in ['y', 'n', '-']) {
    fail('`chroot\' can only be one of +y+, +n+, +-+')
  }

  if ($wakeup != '-' and !is_integer($wakeup)) or
    (is_integer($wakeup) and $wakeup < 0) {
    fail('`wakeup\' can only be +-+ or an integer >= 0')
  }

  if ($limit != '-' and !is_integer($limit)) or
    (is_integer($limit) and $limit < 0) {
    fail('`limit\' can only be +-+ or an integer >= 0')
  }

  validate_string($command)

  $notify_service = $service_autorestart ? {
    undef   => $postfix::service_autorestart,
    default => $service_autorestart,
  }

  $prefix = "set ${service_name}[type=\"${type}\"]"

  if $command_args != undef {
    if is_array($command_args) {
      $command_args_real = join($command_args, "\n  ")
    } elsif is_string($command_args) {
      $command_args_real = $command_args
    } else {
      fail('`command_args\' has to be +undef+, a string or an array of strings')
    }
  } else {
    $command_args_real = undef
  }

  $command_real = $command_args_real ? {
    undef   => $command,
    default => "${command}\n  ${command_args_real}"
  }

  augeas { "${module_name}::master.cf::${name}":
    changes   => [
      "${prefix}/type ${type}",
      "${prefix}/private ${private}",
      "${prefix}/unprivileged ${unprivileged}",
      "${prefix}/chroot ${chroot}",
      "${prefix}/wakeup ${wakeup}",
      "${prefix}/limit ${limit}",
      "${prefix}/command \"${command_real}\"",
    ],
    incl      => "${postfix::config_dir}/master.cf",
    lens      => $lens,
    load_path => $load_path,
  }

  Package[$postfix::package] -> Augeas["${module_name}::master.cf::${name}"]

  if $notify_service {
    Augeas["${module_name}::master.cf::${name}"] ~> Service[$postfix::service]
  }
}
