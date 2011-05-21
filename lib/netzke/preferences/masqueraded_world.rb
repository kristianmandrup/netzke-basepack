require 'netzke/preferences/pref_helper'

module Netzke
  module MasqueradedWorld    
    extend Netzke::PrefHelper
    
    def self.read name 
      first_named_role name, 0      
    end

    def self.write name
      # first, delete all the corresponding preferences for all users and roles
      delete_all(:name => name)
      # then, create the new preference for the World (role_id = 0)
      res = new :name => name, :role_id => 0
    end
  end
end
