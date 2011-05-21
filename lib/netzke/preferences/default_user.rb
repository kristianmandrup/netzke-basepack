require 'netzke/preferences/pref_helper'

module Netzke
  module DefaultUser    
    extend Netzke::PrefHelper
    
    def self.read name
      first_named_role name, 0      
    end

    def self.write name
      res = where :name => name
      res ||= new :name => name
    end
  end
end
