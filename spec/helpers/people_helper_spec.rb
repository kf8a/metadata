require 'spec_helper'

describe PeopleHelper, type: :helper do
  describe "#contact_link" do
    it "should change @ to at" do
      unmodified_email = "sam@example.com"
      fixed_email = "sam at example.com"
      expect(helper.contact_link(unmodified_email)).to eq(fixed_email)
    end
  end
end
