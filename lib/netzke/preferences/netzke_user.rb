require 'netzke/preferences/pref_helper'

module Netzke
  module MasqueradedRole    
    extend Netzke::PrefHelper    

    def self.read name
      user = User.find netzke_user
      # first, get the prefs for this user
      res = first_named_user name, user
      # if it doesn't exist, get them for the user's role
      res ||= first_named_role name, user.role
      # if it doesn't exist either, get them for the World (role_id = 0)
      res ||= first_named_role name, 0
    end
    
    def self.write name
      res = first_named_user name, netzke_user
      res ||= new :name => name, :user_id => netzke_user
    end
  end
end