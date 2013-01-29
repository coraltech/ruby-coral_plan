
module Coral
module Plan
class Event < Event
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def self.instance(options = {}, build_hash = false, keep_array = false)
    return instance!(options, build_hash, keep_array) do |type, info|
      type == :plan ? info[:object] : create(type, info)
    end
  end
  
  #---
  
  def initialize(options = {})
    super(options)    
    @plan = ( options.has_key?(:plan) ? options[:plan] : nil )
  end
    
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def set_properties(data)
    super(data)
    @plan.set_event(@name, nil, @properties) if @plan
    return self
  end
  
  #---
  
  def set_property(name, value)
    super(data)
    @plan.set_event(@name, name, @properties[name]) if @plan
    return self
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def self.build_info(data = {})
    return build_info!(data) do |element|
      event = {}
             
      case element        
      when String
        if @plan && @plan.events.has_key?(element)
          event[:type]   = :plan
          event[:object] = @plan.events[element]
        else
          event = split_event_string(element)
        end        
      when Hash          
        event = element
      end
      
      if @plan
        event[:delegate] = self.new({
          :name => element[:name],
          :plan => @plan,
        })
      end      
      event
    end
  end
end
end
end
