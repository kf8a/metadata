# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class CoreAreaTest < ActiveSupport::TestCase
  should have_and_belong_to_many :datatables
end

# == Schema Information
#
# Table name: core_areas
#
#  id   :integer         not null, primary key
#  name :string(255)
#
