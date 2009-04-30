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

    it "should have the callback as a private method" do
      @post = Post.new
      @post.private_methods.should include("save_comments")
    end

    describe "with a new record" do
      before do
        @post = Post.new
      end

      it "should build one new record" do
        @post.comment_attributes = [{ :body => "foo" }]
        
        @post.comments.size.should == 1
        @post.comments.first.body.should == "foo"
      end
   
      it "should build multiple records" do
        @post.comment_attributes = [{ :body => "foo" }, { :body => "bar"} ]
   
        @post.comments.size.should == 2
      end
    end

    describe "with a saved record" do
      before do
        @post = Post.new
        @comment = @post.comments.build
        @post.save!
      end

      it "should delete a record which is not given" do
        @post.comment_attributes = { }
        @post.comments.size.should == 1
      end

      it "should not delete a record if given in the attributes" do
        @post.comment_attributes = { @comment.id.to_s => { :body => @comment.body } }
        @post.comments.size.should == 1
      end

      it "should update the attributes when updated" do
        @post.comment_attributes = { @comment.id.to_s => { :body => "foobar" }}
        @comment.body.should == "foobar"
      end

      it "should not alter new records" do
        $debug = true

        c = @post.comments.build
        c.should_not_receive(:delete)

        @post.comment_attributes = { @comment.id.to_s => { :body => @comment.body}}
        
        @post.comments.size.should == 2
      end
    end
  end
end
