module Rrutils

  ###
  # This modul represents a mixin for a set of convenience methods
  # that work with options representing method's parameters.
  module Options

    ###
    # Verifies given options against a pattern that defines checks applied on each option.
    # The pattern is a Hash where property is an expected option's property and value can be:
    # * :optional - corresponding option may or may not be presented
    # * :mandatory - corresponding option has to be presented
    # * Array - corresponding option has to be presented and value has to be in the given list
    #
    # Usage:
    # verify_options(options_to_be_verified, {:foo=>:mandatory, :bar=>[true, false], :baz=>:optional})
    #
    def verify_options(options, pattern)
      raise ArgumentError, 'options cannot be nil' if options.nil?
      raise ArgumentError, 'options is not Hash' unless options.is_a? Hash

      raise ArgumentError, 'pattern cannot be nil' if pattern.nil?
      raise ArgumentError, 'pattern cannot be empty' if pattern.empty?
      raise ArgumentError, 'pattern is not Hash' unless pattern.is_a? Hash

      # unknown key?
      options.keys.each do |k|
        raise ArgumentError, "unknow option: #{k}" unless pattern.keys.include? k
      end
      # missing mandatory option?
      pattern.each do |k,v|
        # :mandatory
        if v == :mandatory
          raise ArgumentError, "missing mandatory option: #{k}" unless options.keys.include? k
        else if v.is_a? Array
          raise ArgumentError, "value '#{options[k]}' not in #{v.inspect}, key=#{k}" unless v.include?(options[k])
        end
      end

      options
    end

    ###
    # The same as <code>verify_options</code> with opportunity to define default values
    # of paramaters that will be set if missing in options.
    #
    # Usage:
    # verify_and_sanitize_options(options_to_be_verified, {:foo=>'defaultValue', :bar=>100})
    #
    def verify_and_sanitize_options(options, pattern)
      verify_options(options, pattern)

      # set default values if missing in options
      pattern.each do |k,v|
        options[k] = v if !v.nil? and v != :optional and !options.keys.include? k
      end
      options
    end

  end

end
