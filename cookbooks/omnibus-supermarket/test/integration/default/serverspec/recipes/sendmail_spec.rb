require 'spec_helper'

describe 'omnibus-supermarket::sendmail' do
  describe package('sendmail') do
    it { should be_installed }
  end
end
