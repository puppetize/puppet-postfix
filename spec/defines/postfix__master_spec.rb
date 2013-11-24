require 'spec_helper'

describe 'postfix::master' do

  let(:title) { 'mysuperservice' }

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end

  context "Set service and trigger postfix service" do
    let :params do
      {
        :type         => 'inet',
        :private      => '-',
        :unprivileged => '-',
        :chroot       => '-',
        :wakeup       => '-',
        :limit        => '-',
        :command      => 'smptd',
        :command_args => '-o something=somewhere'
      }
    end

    it {
      should contain_augeas('postfix::master.cf::mysuperservice').with_notify('Service[postfix]')
    }
  end

  context "Set service and do not trigger postfix service" do
    let :params do
      {
        :type                => 'inet',
        :private             => '-',
        :unprivileged        => '-',
        :chroot              => '-',
        :wakeup              => '-',
        :limit               => '-',
        :command             => 'smptd',
        :command_args        => '-o something=somewhere',
        :service_autorestart => false,
      }
    end

    it {
      should contain_augeas('postfix::master.cf::mysuperservice').without_notify
    }
  end

  context "Set wrong parameters" do
    let :params do
      {
        :type                => 'inet',
        :private             => 'u',
        :unprivileged        => '-',
        :chroot              => '-',
        :wakeup              => '-',
        :limit               => '-',
        :command             => 'smptd',
        :command_args        => '-o something=somewhere',
        :service_autorestart => false,
      }
    end

    it {
      expect {
        should contain_augeas('postfix::master.cf::mysuperservice')
      }.to raise_error(Puppet::Error)
    }
  end

  # TODO complete the tests
end
