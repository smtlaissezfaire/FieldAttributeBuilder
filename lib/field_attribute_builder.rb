module FieldAttributeBuilder
  MAJOR = 0
  MINOR = 0
  TINY  = 1

  VERSION = "#{MAJOR}.#{MINOR}.#{TINY}"

  module ActiveRecordExtensions
    def field_attr_builder(association_name, options={})
      FieldAttributeCreator.install(self, association_name, options)
    end
  end

  class FieldAttributeCreator
    def self.install(model, association_name, options)
      new(model, association_name, options).install
    end

    def initialize(model, association_name, options)
      @model = model
      @association_name = association_name
      @singular_name    = association_name.to_s.singularize
      @options          = options
    end
  
    def install
      install_methods
      register_callback
    end
    
    def install_methods
      @model.class_eval <<-HERE, __FILE__, __LINE__
        def new_#{@singular_name}_attributes=(attribute_groups)
          attribute_groups.each do |attrs|
            #{build_association_text}
          end
        end
  
        def existing_#{@singular_name}_attributes=(attribute_groups)
          records = #{@association_name}.reject { |obj| obj.new_record? }
       
          records.each do |record|
            if attributes = attribute_groups[record.id.to_s]
              record.attributes = attributes
            else
              #{@association_name}.delete(record)
            end
          end
        end
        
      private

        def save_#{@association_name}
          #{@association_name}.each { |obj| obj.save(false) }
        end
      HERE
    end
    
    def register_callback
      @model.after_update(callback_name)
    end
  
  private
  
    def build_association_text
      str = "#{@association_name}.build(attrs)"
      str << " if !attrs.values.all? { |v| v.blank? }" if reject_empty_associations?
      str
    end
  
    def reject_empty_associations?
      @options[:reject_empty] == true ? true : false
    end
  
    def callback_name
      :"save_#{@association_name}"
    end
  end
end
