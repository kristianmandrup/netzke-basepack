require 'netzke/preferences/pref_helper'

module Netzke
  module MasqueradedRole    
    extend Netzke::PrefHelper    

    def self.read name
      # first, get the prefs for this role
      res = first_named_role name, masqueraded_role
      # if it doesn't exist, get them for the World (role_id = 0)
      res ||= first_named_role name, 0
    end
    
    def self.write name
      # first, delete all the corresponding preferences for the users that have this role
      Role.find(masqueraded_role).users.each do |user|
        delete_all :name => name, :user_id => user
      end
      first_named_role(name, masqueraded_role) || new(:name => name, :role_id => masqueraded_role)
    end
  end
end

