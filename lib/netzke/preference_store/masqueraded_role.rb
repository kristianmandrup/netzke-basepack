require 'netzke/preferences/pref_helper'

module Netzke
  module PreferenceStore
    module MasqueradedRole    
      extend Netzke::PrefHelper    

      # get the prefs for this role 
      # if it doesn't exist, get them for the World (role_id = 0)
      def self.read name      
        first_named_role(name, masqueraded_role) || first_named_role(name, nil)
      end

      # delete all the corresponding preferences for the users that have this role    
      # then find the user
      def self.write name      
        Role.find(masqueraded_role).users.each do |user|
          delete_all :name => name, :user_id => user
        end
        first_named_role(name, masqueraded_role) || new(:name => name, :role_id => masqueraded_role)
      end
    end
  end
end

