require 'spec_helper'

describe 'postfix::config' do

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end

  context "With a config content specified" do
    let(:title) { 'someconfigfile' }

    let :params do
      {
        :content => "foo = bar\nsome = other"
      }
    end

    it {
      should contain_file('/etc/postfix/someconfigfile').with({
        'content' => "foo = bar\nsome = other",
        'notify'  => 'Service[postfix]'
      })
    }
  end

  context "With a config template specified" do
    let(:title) { 'sometemplateconfig' }

    let :params do
      {
        :template => 'test_resources/main.cf.erb'
      }
    end

    it {
      should contain_file('/etc/postfix/sometemplateconfig').with_content("thatsa = template\n\n")
    }
  end

  context "With a config template and options specified" do
    let(:title) { 'sometemplateconfig' }

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
      should contain_file('/etc/postfix/sometemplateconfig').with_content("thatsa = template\n\nthis = shouldbethere\nsomething = aboutus\n")
    }
  end

  context "With bad options specified" do
    let(:title) { 'sometemplateconfig' }

    let :params do
      {
        :options => 'something wrong'
      }
    end

    it {
      expect {
        should contain_postfix__config('sometemplateconfig')
      }.to raise_error(Puppet::Error)
    }
  end

  context "With a config content and config_dir specified" do
    let(:title) { 'someconfig' }
    let(:pre_condition) do
      "class { 'postfix': config_dir => '/opt/postfix' }"
    end

    let :params do
      {
        :content    => "foo = bar\nsome = other",
      }
    end

    it {
      should contain_file('/opt/postfix/someconfig').with_content("foo = bar\nsome = other")
    }
  end

  context "Ensure default service_autorestart as true" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content => 'something',
      }
    end

    it {
      should contain_file('/etc/postfix/someconfig').with_notify('Service[postfix]')
    }
  end

  context "Set service_autorestart to false" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :service_autorestart => false,
        :content             => 'something',
      }
    end

    it {
      should contain_file('/etc/postfix/someconfig').without_notify
    }
  end

  context "Wrong post command should fail" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content  => 'something',
        :post_cmd => 'badcommand'
      }
    end

    it {
      expect {
        should contain_postfix__config('someconfig')
      }.to raise_error(Puppet::Error)
    }
  end

  context "Use postmap after config change" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content  => 'something',
        :post_cmd => 'postmap'
      }
    end

    # default should not notify through the file but through the exec
    it {
      should contain_file('/etc/postfix/someconfig').without_notify
      should contain_exec('postmap /etc/postfix/someconfig').with_notify('Service[postfix]').with_subscribe('File[/etc/postfix/someconfig]')
    }
  end
  
  context "Use postalias after config change" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content  => 'something',
        :post_cmd => 'postalias'
      }
    end

    it {
      should contain_file('/etc/postfix/someconfig').without_notify
      should contain_exec('postalias /etc/postfix/someconfig').with_notify('Service[postfix]').with_subscribe('File[/etc/postfix/someconfig]')
    }
  end

  context "Use postalias after config change with specified file type" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content   => 'something',
        :post_cmd  => 'postalias',
        :file_type => 'dbms'
      }
    end

    it {
      should contain_file('/etc/postfix/someconfig').without_notify
      should contain_exec('postalias dbms:/etc/postfix/someconfig').with_notify('Service[postfix]').with_subscribe('File[/etc/postfix/someconfig]')
    }
  end

  context "Specified file type without a post command" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content   => 'something',
        :file_type => 'dbms'
      }
    end

    it {
      expect {
        should contain_postfix__config('someconfig')
      }.to raise_error(Puppet::Error)
    }
  end

  context "Use postalias after config change without notifying postfix" do
    let(:title) { 'someconfig' }

    let :params do
      {
        :content             => 'something',
        :post_cmd            => 'postalias',
        :service_autorestart => false,
      }
    end

    it {
      should contain_file('/etc/postfix/someconfig').without_notify
      should contain_exec('postalias /etc/postfix/someconfig').without_notify.with_subscribe('File[/etc/postfix/someconfig]')
    }
  end
end
