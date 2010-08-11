require File.dirname(__FILE__) + '/../test_helper'
require 'shoulda'

class TemplateTest < ActiveSupport::TestCase
 should belong_to :website
 
end
