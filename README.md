puppet-postfix
==============

Module to install/configure/manage postfix.

## Hiera

The _params_ paradigm is used. So look into postfix::params to see
what you can override through hiera (Puppet >= 3).

## Usage

### simple install

This will install postfix and won't touch any configuration shipped
with the package provider:

```puppet
include postfix
```

### override/set some parameters

This will install postfix and will change/set the parameters in the
main.cf (better use hiera or postfix::conf instead of the
parameterized class):

```puppet
class { 'postfix':
  options => {
    'message_size_limit' => '10240000',
    'allow_min_user'     => true,
  },
}
```

### manage main.cf completely

This will install postfix and overrides the main.cf with a template
you provide (and the _options_ variable is given through so that
the stuff can be used inside the template):

```puppet
class { 'postfix':
  template => 'my_site/postfix/main.cf.erb',
  options => {
    'message_size_limit' => '10240000',
    'allow_min_user'     => true,
  },
}
```

Keep in mind that _postfix::conf_ is not working if the main.cf is
completely managed by puppet!

### Set some options dynamically through postfix::conf or postfix_conf

If you want to manage the main.cf more dynamically to be able to extend
the default configuration you could use the define _postfix::conf_ or
using the function postfix_conf:

```puppet
postfix::conf {
  'message_size_limit':
    value => '10240000';
  'allow_min_user':
    value => true;
}

postfix_conf({
  'message_size_limit' => '10240000',
  'allow_min_user'     => true,
})
```
