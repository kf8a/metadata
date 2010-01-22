require File.dirname(__FILE__) + '/../test_helper'

class ProtocolTest < ActiveSupport::TestCase

  Factory.define :protocol do |p|
    p.name 'First protocol'
  end
  
end
