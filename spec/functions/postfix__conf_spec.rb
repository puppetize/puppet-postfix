require 'spec_helper'

describe 'postfix_conf' do
  context "Fail on missing parameters" do
    it {
      should run.with_params().and_raise_error(ArgumentError)
    }
  end

  context "Fail on wrong parameters" do
    it {
      should run.with_params([1,2,3]).and_raise_error(ArgumentError)
      should run.with_params({'a' => [1,2,3]}).and_raise_error(ArgumentError)
    }
  end

  context "No erros with valid parameters" do
    it {
      should run.with_params({
        'mailbox_size_limit' => 1234567,
        'something'          => 'somewhere'
      })
    }
  end

  # TODO test if it creates postfix::conf
  #      but this is somehow covered by the init.pp tests
end
