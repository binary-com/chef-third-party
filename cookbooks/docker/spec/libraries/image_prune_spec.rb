# TODO: Refactor test
require 'spec_helper'
require_relative '../../libraries/helpers_json'

RSpec.describe DockerCookbook::DockerHelpers::Json do
  class DummyClass < Chef::Node
    include DockerCookbook::DockerHelpers::Json
  end

  subject { DummyClass.new }

  describe '#generate_json' do
    it 'generates filter json' do
      dangling = true
      prune_until = '1h30m'
#      with_label = 'com.example.vendor=ACME'
#      without_label = 'no_prune'
      expected = 'filters=%7B%22dangling%22%3A%7B%22true%22%3Atrue%7D%2C%22until%22%3A%7B%221h30m%22%3Atrue%7D%2C'

      expect(subject.generate_json(dangling, prune_until)).to eq(expected)
    end
  end
end
