require 'spec_helper'

describe 'postfix::master' do

  let(:title) { 'mysuperservice|unix' }

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end

  context "Set service and trigger postfix service" do
    let :params do
      {
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
      should contain_augeas('postfix::master.cf::mysuperservice|unix').with_notify('Service[postfix]')
    }
  end

  context "Set service and do not trigger postfix service" do
    let :params do
      {
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
      should contain_augeas('postfix::master.cf::mysuperservice|unix').without_notify
    }
  end

  context "Set wrong parameters" do
    let :params do
      {
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

  context "Set wrong type" do
    let(:title) { 'mysuperservice|something' }

    let :params do
      {
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
        should contain_augeas('postfix::master.cf::mysuperservice|something')
      }.to raise_error(Puppet::Error)
    }
  end

  context "Set no type" do
    let(:title) { 'mysuperservice' }

    let :params do
      {
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

  context "Use wrong naming schema" do
    let(:title) { 'mysuperservice|something|unix' }

    let :params do
      {
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
        should contain_augeas('postfix::master.cf::mysuperservice|something|unix')
      }.to raise_error(Puppet::Error)
    }
  end

  # TODO complete the tests
end
