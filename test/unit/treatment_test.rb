require File.expand_path('../../test_helper',__FILE__)

class TreatmentTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end





# == Schema Information
#
# Table name: treatments
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  study_id    :integer
#  weight      :integer
#

