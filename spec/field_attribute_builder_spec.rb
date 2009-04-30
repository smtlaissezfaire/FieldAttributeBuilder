require File.dirname(__FILE__) + "/spec_helper"

describe FieldAttributeBuilder do
  describe "Version" do
    it "should be at version 0.0.1" do
      FieldAttributeBuilder::VERSION.should == "0.0.1"
    end
  end

  describe "with has_many" do
    before do
      Post.class_eval do
        field_attr_builder :comments
      end
    end

    it "should save the associated records" do
      @post = Post.new
      comment = @post.comments.build
      
      @post.save!
      @post.reload
      
      @post.comments.should == [comment]
    end

    it "should build one new record" do
      @post = Post.new
      @post.new_comment_attributes = [{ :body => "foo" }]
      
      @post.comments.size.should == 1
      @post.comments.first.body.should == "foo"
    end

    it "should build multiple records" do
      @post = Post.new
      @post.new_comment_attributes = [{ :body => "foo" }, { :body => "bar"} ]

      @post.comments.size.should == 2
    end
  end
end
