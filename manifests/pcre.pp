# Simple helper class to install postfix pcre extension
class postfix::pcre {
  case $::osfamily {
    'Debian': {
      package { 'postfix-pcre':
        ensure => installed
      }
    }

    default: {
      fail("${::osfamily} is not supported right now")
    }
  }
}
