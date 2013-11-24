require 'spec_helper'

describe 'postfix', :type => 'class' do

  context "On a Debian OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it {
      should contain_package('postfix').with( { 'name' => 'postfix' } )
      should contain_service('postfix').with( { 'name' => 'postfix' } )
    }
  end

  context "On an unknown OS with no package name specified" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end

  context "With a package and service name specified" do
    let :params do
      {
        :package => 'postfix2.10',
        :service => 'postfix-dev'
      }
    end

    it {
      should contain_package('postfix2.10')
      should contain_service('postfix-dev')
    }
  end

  context "With a config content specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    let :params do
      {
        :content => "foo = bar\nsome = other"
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with( { 'content' => "foo = bar\nsome = other" } )
    }
  end

  context "With a config template specified" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    let :params do
      {
        :template => "foo = bar\nsome = other"
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with( { 'content' => "foo = bar\nsome = other" } )
    }
  end
end
