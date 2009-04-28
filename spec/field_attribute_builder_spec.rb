require File.dirname(__FILE__) + "/spec_helper"

describe FieldAttributeBuilder do
  describe "Version" do
    it "should be at version 0.0.1" do
      FieldAttributeBuilder::VERSION.should == "0.0.1"
    end
  end
end
