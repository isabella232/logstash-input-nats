class String
  def numeric?
    Float(self) != nil rescue false
  end
end

class Hash
  def convert_number_string_to_float(value=nil)
    #puts "Got value=#{value}"
    if value.nil?
      # First call we just need to recursively call the function
      # on all its values
      self.each do |key, sub_value|
        self[key] = convert_number_string_to_float(sub_value)
      end
    elsif value.respond_to? :each
      # If the incoming value is a iterable we also want to further recurse
      # the DS
      if value.kind_of?(Hash)
        value.each do |key, sub_value|
          value[key] = convert_number_string_to_float(sub_value)
        end
      else
        value.each_with_index do |sub_value, index|
          value[index] = convert_number_string_to_float(sub_value)
        end
      end
    else
      if value.kind_of?(String) and value.numeric?
        Float(value)
      else
        value
      end
    end
  end
end
