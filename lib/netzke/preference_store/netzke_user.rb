require 'netzke/preferences/pref_helper'

module Netzke
  module PreferenceStore
    module MasqueradedRole    
      extend Netzke::PrefHelper    

      # get the prefs for this user
      # if it doesn't exist, get them for the user's role
      # if it doesn't exist either, get them for the World (role_id = 0)
      def self.read name      
        first_named_user(name, user) || first_named_role(name, user.role) || first_named_role(name, nil)
      end
    
      def self.write name
        res = first_named_user name, netzke_user
        res ||= new :name => name, :user => netzke_user
      end
    
      def self.user
        user = User.find netzke_user
      end
    end
  end
end