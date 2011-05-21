module Netzke
  module PrefHelper    
    # include Netzke::Session
    
    def self.included(base)
      base.send :include, Netzke::Session
    end

    def first_named_user name, user
      first_named name, :user_id => user
    end

    def first_named_role name, role
      first_named name, :role_id => role
    end

    def first_named name, condition = {}                        
      where(condition.merge :name => name.to_s).first
    end
  end
end