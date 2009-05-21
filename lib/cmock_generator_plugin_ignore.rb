
class CMockGeneratorPluginIgnore

  attr_reader :config, :utils, :tab
  
  def initialize(config, utils)
    @config = config
	  @tab = @config.tab
    @utils = utils

    ["ignore_bool_type"].each do |req|
      raise "'#{req}' needs to be defined in config" unless @config.respond_to?(req)
    end
  end
  
  def instance_structure(function)
    return "#{@tab}#{@config.ignore_bool_type} #{function[:name]}_IgnoreBool;\n"
  end
  
  def mock_function_declarations(function)
    if (function[:return_type] == "void")
      return "void #{function[:name]}_Ignore(void);\n"
    else        
      return "void #{function[:name]}_IgnoreAndReturn(#{function[:return_string]});\n"
    end 
  end
  
  def mock_implementation_prefix(function)
    [ "#{@tab}if (Mock.#{function[:name]}_IgnoreBool)\n",
      "#{@tab}{\n",  
      (function[:return_type] == "void") ? "#{@tab}#{@tab}return;\n" : @utils.code_handle_return_value(function, "#{@tab}#{@tab}"),
      "#{@tab}}\n" ]
  end
  
  def mock_interfaces(function)
    if (function[:return_type] == "void")
      [ "void #{function[:name]}_Ignore(void)\n",
        "{\n",
        "#{@tab}Mock.#{function[:name]}_IgnoreBool = (unsigned char)1;\n",
        "}\n\n" ]
    else
      [ "void #{function[:name]}_IgnoreAndReturn(#{function[:return_string]})\n",
        "{\n",
        "#{@tab}Mock.#{function[:name]}_IgnoreBool = (unsigned char)1;\n",
        @utils.code_insert_item_into_expect_array(function[:return_type], "Mock.#{function[:name]}_Return_Head", CMOCK_RETURN_PARAM_NAME),
        "#{@tab}Mock.#{function[:name]}_Return = Mock.#{function[:name]}_Return_Head;\n",
        "#{@tab}Mock.#{function[:name]}_Return += Mock.#{function[:name]}_CallCount;\n",
        "}\n\n" ]
    end
  end
end
