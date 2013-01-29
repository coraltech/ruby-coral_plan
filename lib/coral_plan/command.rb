
module Coral
module Plan
class Command < Command
 
  #-----------------------------------------------------------------------------
  # Constructor / Destructor

  def initialize(options = {})
    super(options)    
    @plan = ( options.has_key?(:plan) ? options[:plan] : nil )
  end
     
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  def command=command
    super(command)
    @plan.set_command(@name, "command", command) if @plan
  end
  
  #---
  
  def vagrant=command
    super(command)
    @plan.set_command(@name, "vagrant", command) if @plan
  end
  
  #---
  
  def cloud=command
    super(command)    
    @plan.set_command(@name, "cloud", command) if @plan
  end
  
  #---
  
  def args=args
    super(args)
    @plan.set_command(@name, "args", @properties[:args]) if @plan
  end
  
  #---
  
  def flags=flags
    super(flags)
    @plan.set_command(@name, "flags", @properties[:flags]) if @plan
  end
  
  #---
  
  def data=data
    super(data)
    @plan.set_command(@name, "data", @properties[:data]) if @plan
  end
  
  #---
  
  def subcommand=subcommand
    super(subcommand)
    @plan.set_command(@name, "subcommand", @properties[:subcommand]) if @plan
  end
  
  #---
  
  def events
    events = {}
    if @plan
      event_types = @plan.command(@name, 'events', [], :array)
      @plan.events.each do |name, event|
        if event_types.include?(event.type)
          events[name] = @plan.events[name]
        end
      end
    end
    return events
  end
   
  #---
  
  def events=events
    @plan.set_command(@name, "events", events) if @plan
  end
 
  #-----------------------------------------------------------------------------
  # Command functions
  
  def build(components = {}, overrides = nil, override_key = false)
    if overrides && ! overrides.empty?
      overrides = translate_events(overrides)
    end
    return super(translate_events(components), overrides, override_key)
  end
  
  #---
  
  def exec!(options = {}, action = nil)
    triggered_events = {}
    action_info      = action
    
    if action && ! action.is_a?(Hash)
      action_info = action.export
    end
    
    success = super(options, action_info) do |line|
      result = true
      prefix = false
      
      if @plan
        @plan.events.each do |name, event|
          if events.has_key?(name) && event.check(line)
            prefix = 'EVENT'
            triggered_events[name] = event
          end
        end
      end
      
      if block_given?
        result = yield(line)
        
        if result && result.is_a?(Hash)
          result = result[:success]                 
        end
      end
      prefix ? { :success => result, :prefix => prefix } : result
    end
       
    if @plan && action
      if success
        action.trigger_success.each do |name|
          triggered_events[name] = @plan.events[name]  
        end
      else
        action.trigger_failure.each do |name|
          triggered_events[name] = @plan.events[name]  
        end
      end
    end
    
    return ( success ? triggered_events : nil )
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
  
  def translate_events(data, options = [ :exit ])
    if @plan && data && data.is_a?(Hash) && data.has_key?(:data)
      data[:data].each do |key, value|
        # Action with command specific overrides
        if value.is_a?(Hash)
          value.each do |sub_key, sub_value|
            if options.include?(sub_key) && @plan.command(key, 'coral', false)
              events = []
              array(sub_value.split(',')).each do |event_name|
                if @plan.events.has_key?(event_name)
                  events << @plan.events[event_name].export
                else
                  events << event_name
                end
              end
              data[:data][key][sub_key] = events.join(',')
            end
          end
        # Command or Action with overrides for all commands
        elsif options.include?(key)
          if data.has_key?(:commands)
            array(data[:commands]).each do |command_name|
              return data unless @plan.command(command_name, 'coral', false)
            end
          end
      
          events = []
          array(value.split(',')).each do |event_name|
            if @plan.events.has_key?(event_name)              
              events << @plan.events[event_name].export
            else
              events << event_name
            end
          end
          data[:data][key] = events.join(',')          
        end
      end
    end
    return data
  end  
end
end
end