
module Coral
module Plan

class ExecuteError < StandardError 
end

class Base < Memory

  #-----------------------------------------------------------------------------
  # Properties
  
  @@instances = {}
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def self.create(name, options = {})
    options[:name] = name unless options.has_key?(:name)
    @@instances[name] = new(options) 
    return @@instances[name]  
  end
  
  #---
  
  def self.delete(name) 
    if @@instances.has_key?(name) && @@instances[name]
      @@instances.delete(name) 
    end  
  end
  
  #-----------------------------------------------------------------------------
 
  def self.[](name)
    if ! @@instances.has_key?(name) || ! @@instances[name]
      @@instances[name] = new({ :name => name })
    end 
    return @@instances[name]  
  end
  
  #-----------------------------------------------------------------------------
  
  def initialize(options = {})
    super(options)
    
    @home = ( options.has_key?(:home) && options[:home].is_a?(Coral::Repository) ? options[:home] : self )  
        
    @start_commands = []
    @commands       = {}
    @events         = {}
    @actions        = {}
  end
    
  #-----------------------------------------------------------------------------
  # Property accessors / modifiers
  
  attr_reader :home

  #---
  
  def home=home
    if home && home.is_a?(Coral::Repository)
      @home = home
      set_repository(@home.directory, @submodule)
    end
  end
  
  #---
  
  def submodule=submodule
    set_repository(@home.directory, submodule)
  end
   
  #-----------------------------------------------------------------------------
  
  def start(reset = false)
    if reset || @start_commands.empty?
      @start_commands = []
      get('start', [], :array).each do |name|
        @start_commands << commands[name]
      end
    end
    return @start_commands
  end
  
  #-----------------------------------------------------------------------------
    
  def commands(reset = false)
    if reset || @commands.empty?
      @commands = {}
      get('commands', {}, :hash).each do |name, command_info|
        command_info = Coral::Util::Data.merge([ {
          :plan   => self,
          :name   => name,
        }, symbol_map(command_info) ])
        
        @commands[name] = Coral::Plan::Command.new(command_info)
      end
    end
    return @commands
  end
    
  #---
    
  def set_commands(commands = {})
    return set('commands', events)
  end
 
  #---
    
  def command(name, key = nil, default = {}, format = false)
    return get_group('commands', name, key, default, format)
  end
    
  #---

  def set_command(name, key = nil, value = {})
    return set_group('commands', name, key, value)
  end
    
  #---

  def delete_command(name, key = nil)
    return delete_group('commands', name, key)
  end
    
  #-----------------------------------------------------------------------------
    
  def events(reset = false)
    if reset || @events.empty?
      @events = {}
      get('events', {}, :hash).each do |name, event_info|
        event_info = Coral::Util::Data.merge([ {
          :plan   => self,
          :name   => name,
        }, symbol_map(event_info) ])
      
        @events[name] = Coral::Plan::Event.instance(event_info)
      end
    end
    return @events
  end
    
  #---
    
  def set_events(events = {})
    return set('events', events)
  end
 
  #---
    
  def event(name, key = nil, default = {}, format = false)
    return get_group('events', name, key, default, format)
  end
    
  #---

  def set_event(name, key = nil, value = {})
    return set_group('events', name, key, value)
  end
    
  #---

  def delete_event(name, key = nil)
    return delete_group('events', name, key)
  end
  
  #-----------------------------------------------------------------------------
    
  def actions(reset = false)
    if reset || @actions.empty?
      @actions = {}
      get('actions', {}, :hash).each do |name, action_info|
        action_info = Coral::Util::Data.merge([ {
          :plan   => self,
          :name   => name,
        }, symbol_map(action_info) ])
        
        @actions[name] = Coral::Plan::Action.new(action_info)
      end
    end
    return @actions
  end
    
  #---
    
  def set_actions(actions = {})
    return set('actions', actions)
  end
 
  #---
    
  def action(name, key = nil, default = {}, format = false)
    return get_group('actions', name, key, default, format)
  end
    
  #---

  def set_action(name, key = nil, value = {})
    return set_group('actions', name, key, value)
  end
    
  #---

  def delete_action(name, key = nil)
    return delete_group('actions', name, key)
  end
  
  #-----------------------------------------------------------------------------
  # Execution
  
  def run(options)
    success = true
    start.each do |command|
      success = recursive_exec(command, options)
      break unless success
    end
    return success
  end
  
  #---
  
  def recursive_exec(command, options = {}, parent_action = nil)
    success = false
    
    options[:info_prefix]  = 'info' unless options.has_key?(:info_prefix)
    options[:error_prefix] = 'error' unless options.has_key?(:error_prefix)
    
    begin
      triggered_events = command.exec(options, parent_action)
    rescue
      raise Coral::Plan::ExecuteError.new(command.name)
    end
    
    if triggered_events
      success = true
      
      unless triggered_events.empty?
        triggered_events.each do |event_name, event|
          actions.each do |action_name, action|
            if action.events.has_key?(event_name)
              action.commands.each do |subcommand|
                success = recursive_exec(subcommand, options, action)
                break unless success
              end
            end        
            break unless success
          end
          break unless success
        end
      end     
    end
    return success
  end
end
end
end