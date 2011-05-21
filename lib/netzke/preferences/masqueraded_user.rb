require 'netzke/preferences/pref_helper'

module Netzke
  module MasqueradedUser    
    extend Netzke::PrefHelper
    
    def self.read name
      # first, get the prefs for this user it they exist
      res = first_named_user name, masqueraded_user
      # if it doesn't exist, get them for the user's role
      user = User.find(session[:masq_user]) # Mongo ID
      # if it doesn't exist either, get them for the World (role_id = 0)
      res ||= first_named_role(name, user.role.id) || first_named_role(name, 0)
    end
    
    def self.write name
      cond.merge!({:user_id => session[:masq_user]})
      # first, try to find the preference for masq_user
      res = self.find(:first, :conditions => cond)
      # if it doesn't exist, create it
      res ||= self.new(cond)
    end
  end
end