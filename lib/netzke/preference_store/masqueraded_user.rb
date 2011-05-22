require 'netzke/preferences/pref_helper'

module Netzke
  module PreferenceStore
    module MasqueradedUser    
      extend Netzke::PrefHelper

      # get the prefs for this user it they exist    
      # if it doesn't exist, get them for the user's role
      # if it doesn't exist either, get them for the World (role_id = 0)
      def self.read name
        first_named_user(name, masqueraded_user) || first_named_role(name, user.role) || first_named_role(name, nil)      
      end

      # try to find the preference for masq_user 
      # if it doesn't exist, create it    
      def self.write name
        where(:name => name , :user_id => masqueraded_user).first || new(:name => name)
      end
    
      def self.user
        User.find(masqueraded_user)
      end
    end
  end
end