# Method to create postfix::conf resources out of a Hash
require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:postfix_conf,
                                      :type => :statement,
                                      :doc => <<-'ENDOFDOC'
Takes a hash of key/value pairs of postconf(5) parameters.

This example will creates postfix::conf resources (see below).

    postfix_conf({
      'someparameter'    => 'somevalue',
      'anotherparameter' => 'anothervalue',
    })

Same stuff with postfix::conf define:

    postfix::conf {
      'someparameter':
        value => 'somevalue';
      'anotherparameter':
        value => 'anothervalue';
    }

ENDOFDOC
) do |vals|
  raise(ArgumentError, 'Must be a hash') unless vals.size == 1 and vals[0].is_a?(Hash)

  vals[0].each_pair do |parameter, value|
    raise(ArgumentError, 'Parameter has to be a string') unless parameter.is_a?(String)
    raise(ArgumentError, 'Value has to be a string') unless value.is_a?(String)
    Puppet::Parser::Functions.function(:create_resources)
    function_create_resources(["postfix::conf", { parameter => { 'value' => value }}])
  end
end
