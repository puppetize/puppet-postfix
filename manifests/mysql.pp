# Simple helper class to install postfix mysql extension
class postfix::mysql {
  case $::osfamily {
    'Debian': {
      package { 'postfix-mysql':
        ensure => installed
      }
    }

    default: {
      fail("${::osfamily} is not supported right now")
    }
  }
}
