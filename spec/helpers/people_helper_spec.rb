require 'spec_helper'

describe PeopleHelper do
  describe "#contact_link" do
    it "should change @ to at" do
      unmodified_email = "sam@example.com"
      fixed_email = "sam at example.com"
      helper.contact_link(unmodified_email).should eq(fixed_email)
    end
  end
end
