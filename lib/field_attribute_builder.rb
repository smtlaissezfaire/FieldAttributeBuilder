module FieldAttributeBuilder
  module ActiveRecordExtensions
    def field_attr_builder(association_name, object = self)
      FieldAttributeCreator.install(object, association_name)
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
      @model.class_eval <<-HERE
        def new_#{@singular_name}_attributes=(attribute_groups)
          attribute_groups.each { |attrs| #{@association_name}.build(attrs) }
        end
  
        def existing_#{@singular_name}_attributes=(attribute_groups)
          records = #{@association_name}.reject { |obj| obj.new_record? }
       
          records.each do |record|
            if attributes = attribute_groups[record.id.to_s]
              record.attributes = attributes
            else
              records.delete(record)
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
  
    def callback_name
      :"save_#{@association_name}"
    end
  end
end
