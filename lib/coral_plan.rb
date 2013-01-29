
home = File.dirname(__FILE__)

$:.unshift(home) unless
  $:.include?(home) || $:.include?(File.expand_path(home))
  
#-------------------------------------------------------------------------------
  
require 'rubygems'
require 'coral_core'

#---

# Include data model
[ :event, :command, :action, :base ].each do |name| 
  require File.join('coral_plan', name.to_s + '.rb') 
end

#*******************************************************************************
# Coral Execution Plan Library
#
# This provides the ability to create repeatable execution plans that can be
# loaded from and stored into files, among other things...
#
# Author::    Adrian Webb (mailto:adrian.webb@coraltech.net)
# License::   GPLv3
module Coral
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor

  def self.create_plan(name, options = {})
    return Coral::Plan.create(name, options)
  end
  
  #---
  
  def self.delete_plan(name)
    return Coral::Plan.delete(name)
  end
  
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers
  
  def self.plan(name)
    return Coral::Plan[name]
  end

#*******************************************************************************

module Plan
  
  VERSION = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  
  #-----------------------------------------------------------------------------
  # Constructor / Destructor
  
  def self.create(name, options = {})
    return Coral::Plan::Base.create(name, options)
  end
  
  #---
  
  def self.delete(name) 
    return Coral::Plan::Base.delete(name)  
  end
  
  #-----------------------------------------------------------------------------
  # Accessors / Modifiers
 
  def self.[](name)
    return Coral::Plan::Base[name]  
  end
end
end