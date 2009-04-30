module FieldAttributeBuilder
  MAJOR = 0
  MINOR = 0
  TINY  = 1

  VERSION = "#{MAJOR}.#{MINOR}.#{TINY}"

  module ActiveRecordExtensions
    def field_attr_builder(association_name, object = self)
      FieldAttributeCreator.install(object, association_name)
    end
  end

  class AttributeAssigner
    def self.assign(*args)
      new(*args).assign
    end

    def initialize(object, singular_name, association_name, attribute_groups)
      @object = object
      @singular_name = singular_name
      @association_name = association_name
      @attribute_groups = attribute_groups
    end

    def assign
      if @object.new_record?
        assign_new_record
      else
        assign_existing_record
      end
    end

    def assign_new_record
      @attribute_groups.each { |attrs| association.build(attrs) }
    end

  private

    def association
      @object.send(@association_name)
    end

    def assign_existing_record
      records = association.reject { |obj| obj.new_record? }

      records.each do |record|
        if attributes = @attribute_groups[record.id.to_s]
          record.attributes = attributes
        else
          record.delete
        end
      end
    end
  end

  class FieldAttributeCreator
    def self.install(model, association_name)
      new(model, association_name).install
    end

    def initialize(model, association_name)
      @model = model
      @association_name = association_name
      @singular_name    = association_name.to_s.singularize
    end
  
    def install
      install_methods
      register_callback
    end

    def install_methods
      singular_name = @singular_name
      association_name = @association_name

      @model.class_eval do
        define_method :"#{singular_name}_attributes=" do |attribute_groups|
          FieldAttributeBuilder::AttributeAssigner.assign(self, singular_name, association_name, attribute_groups)
        end
      end

      @model.class_eval <<-HERE, __FILE__, __LINE__
        def save_#{@association_name}
          #{@association_name}.each { |obj| obj.save(false) }
        end

        private :#{callback_name}
      HERE
    end
  
    def register_callback
      @model.after_update(callback_name)
    end
  
  private
  
    def callback_name
      :"save_#{@association_name}"
    end
  end
end
