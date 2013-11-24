require 'spec_helper'

describe 'postfix' do
  let :facts do
    {
      :osfamily => 'Debian'
    }
  end


  context "On a Debian OS with no package name specified" do
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
      expect {
        should contain_postfix
      }.to raise_error(Puppet::Error)
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
    let :params do
      {
        :content => "foo = bar\nsome = other"
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with_content("foo = bar\nsome = other")
    }
  end

  context "With a config template specified" do
    let :params do
      {
        :template => 'test_resources/main.cf.erb'
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with_content("thatsa = template\n\n")
    }
  end

  context "With a config template and options specified" do
    let :params do
      {
        :template => 'test_resources/main.cf.erb',
        :options  => [
          ['this', 'shouldbethere'],
          ['something', 'aboutus'],
        ]
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with_content("thatsa = template\n\nthis = shouldbethere\nsomething = aboutus\n")
    }
  end

  context "With a config content and template specified" do
    let :params do
      {
        :content  => "foo = bar\nsome = other",
        :template => "does not matter for test",
      }
    end

    it {
      expect {
        should contain_postfix
      }.to raise_error(Puppet::Error)
    }
  end
  context "With bad options specified" do
    let :params do
      {
        :options => 'something wrong'
      }
    end

    it {
      expect {
        should contain_postfix
      }.to raise_error(Puppet::Error)
    }
  end

  context "With good options specified" do
    let :params do
      {
        :options => {
          'someparameters' => 'withvalues',
          'many'           => 'of them',
        }
      }
    end

    it {
      should contain_postfix__conf('someparameters').with_value('withvalues')
      should contain_postfix__conf('many').with_value('of them')
    }
  end

  context "With a config content and config_dir specified" do
    let :params do
      {
        :content    => "foo = bar\nsome = other",
        :config_dir => '/opt/postfix'
      }
    end

    it {
      should contain_file('/opt/postfix/main.cf').with_content("foo = bar\nsome = other")
    }
  end

  context "Ensure default service_autorestart as true" do
    let :params do
      {
        :content => 'something',
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').with_notify('Service[postfix]')
    }
  end

  context "Set service_autorestart to false" do
    let :params do
      {
        :service_autorestart => false,
        :content             => 'something',
      }
    end

    it {
      should contain_file('/etc/postfix/main.cf').without_notify('Service[postfix]')
    }
  end
end
