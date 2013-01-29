
module Coral
module Plan
class Action < Core
 
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def initialize(options = {})
    super(options)
    @plan = ( options.has_key?(:plan) ? options[:plan] : nil )
    @name = ( options.has_key?(:name) ? string(options[:name]) : '' )      
  end  
      
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  attr_accessor :name

  #---
  
  def events
    events = {}
    @plan.action(@name, 'events', [], :array).each do |name|
      events[name] = @plan.events[name]
    end
    return events
  end
  
  #---
  
  def events=events
    @plan.set_action(@name, "events", events)  
  end
  
  #---
  
  def commands
    commands = []
    @plan.action(@name, 'commands', [], :array).each do |name|
      commands << @plan.commands[name]
    end
    return commands
  end
  
  #---
  
  def commands=commands
    @plan.set_action(@name, "commands", commands)  
  end
  
  #---
      
  def args
    return search('args', :array)
  end
  
  #---
  
  def args=args
    @plan.set_action(@name, "args", args)  
  end
  
  #---
    
  def flags
    return search('flags', :array)
  end
  
  #---
  
  def flags=flags
    @plan.set_action(@name, "flags", flags)  
  end
  
  #---
    
  def data
    return search('data', :hash)
  end
   
  #---
  
  def data=data
    @plan.set_action(@name, "data", data)  
  end
  
  #---
    
  def next
    commands = []
    @plan.action(@name, 'next', [], :array).each do |name|
      commands << @plan.commands[name]
    end
    return commands
  end
   
  #---
  
  def next=commands
    @plan.set_action(@name, "next", commands)  
  end
  
  #---
    
  def trigger_success
    return @plan.action('trigger_success', :array)
  end
   
  #---
  
  def trigger_success=event_names
    @plan.set_action(@name, "trigger_success", array(event_names))  
  end
  
  #---
    
  def trigger_failure
    return @plan.action('trigger_failure', :array)
  end
   
  #---
  
  def trigger_failure=event_names
    @plan.set_action(@name, "trigger_failure", array(event_names))  
  end
  
  #-----------------------------------------------------------------------------
  # Import / Export
  
  def export
    return symbol_map(@plan.action(@name))
  end
  
  #-----------------------------------------------------------------------------
  # Utilities
    
  def search(key, format = :array)
    action_info  = @plan.action(@name)
    action_value = map(action_info[key])
    
    merged_value = {}
    
    commands.each do |command|
      command_info  = command.export
      command_value = ( command_info[key] ? { command.name => filter(command_info[key], format) } : {} )
           
      merged_value[name] = Coral::Util::Data.merge([ action_value, command_value ], true)
    end        
    return merged_value  
  end
  
  #---
   
  def map(data)
    if data && ! data.is_a?(Hash)
      data_map = {}
      commands.each do |command|
        data_map[command.name] = array(data)
      end
      data = data_map
    end
    return data  
  end  
end
end
end