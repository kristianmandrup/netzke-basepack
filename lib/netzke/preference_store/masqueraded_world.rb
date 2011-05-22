require 'netzke/preferences/pref_helper'

module Netzke
  module PreferenceStore
    module MasqueradedWorld    
      extend Netzke::PrefHelper
    
      def self.read name 
        first_named_role name, nil      
      end

      # delete all the corresponding preferences for all users and roles
      # then, create the new preference for the World (role_id = 0)
      def self.write name      
        delete_all(:name => name)      
        new :name => name, :role => nil
      end
    end
  end
end