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
      
      @post = Post.new
    end

    it "should save the associated records" do
      comment = @post.comments.build
      
      @post.save!
      @post.reload
      
      @post.comments.should == [comment]
    end

    it "should build one new record" do
      @post.new_comment_attributes = [{ :body => "foo" }]
      
      @post.comments.size.should == 1
      @post.comments.first.body.should == "foo"
    end

    it "should build multiple records" do
      @post.new_comment_attributes = [{ :body => "foo" }, { :body => "bar"} ]

      @post.comments.size.should == 2
    end
    
    it "should build empty attributes" do
      @post.new_comment_attributes = [{:body => ""}]
      @post.comments.size.should == 1
    end
  end
  
  describe "rejecting empty attributes" do
    before do
      Post.class_eval do
        field_attr_builder :comments, :reject_empty => true
      end
    end
    
    describe "with new records" do
      before do
        @post = Post.new
      end
      
      it "should build one regularly" do
        @post.new_comment_attributes = [{:body => "foo"}]
        @post.comments.size.should == 1
      end
      
      it "should not build one if all of the attributes are empty" do
        @post.new_comment_attributes = [{:body => ""}]
        @post.comments.size.should == 0
      end
      
      it "should delete records which were previously saved, but are no longer passed" do
        @post = Post.new
        @post.save!
        @post.comments.create!
        @post.reload
      
        @post.existing_comment_attributes = {}
        @post.reload
      
        @post.comments.size.should == 0
      end
    end
  end
end
