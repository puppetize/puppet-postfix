require 'spec_helper'

describe 'postfix::conf' do
  let(:title) { 'message_size_limit' }

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end

  context "Fail if main.cf is fully managed by puppet" do
    let(:pre_condition) do
      "class { 'postfix': content => 'something' }"
    end

    let :params do
      {
        :value    => '1234567'
      }
    end

    it {
      expect {
        should contain_postfix__conf('message_size_limit')
      }.to raise_error(Puppet::Error)
    }
  end

  context "Set parameter and trigger postfix service" do
    let :params do
      {
        :value    => '1234567'
      }
    end

    it {
      should contain_exec('postconf message_size_limit').with({
        'command' => "postconf -e 'message_size_limit'='1234567'",
        'notify'  => 'Service[postfix]',
      })
    }
  end

  context "Set parameter and do not trigger postfix service" do
    let(:pre_condition) do
      "class { 'postfix': service_autorestart => false }"
    end

    let :params do
      {
        :value    => '1234567'
      }
    end

    it {
      should contain_exec('postconf message_size_limit').with_command('postconf -e \'message_size_limit\'=\'1234567\'').without_notify
    }
  end
end
