require File.expand_path('../../test_helper',__FILE__)

class SpeciesTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end





# == Schema Information
#
# Table name: species
#
#  id                    :integer         not null, primary key
#  species               :string(255)
#  genus                 :string(255)
#  family                :string(255)
#  code                  :string(255)
#  common_name           :string(255)
#  alternate_common_name :string(255)
#  attribution           :string(255)
#  woody                 :boolean
#

