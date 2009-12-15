module Representative
  
  class ObjectInspector
    
    def get_value(object, attribute_name)
      object.send(attribute_name)
    end

    def get_metadata(object, attribute_name)
      {}
    end
    
  end
  
end