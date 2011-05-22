require 'netzke/preferences/pref_helper'

module Netzke
  module PreferenceStore
    module Default    
      extend Netzke::PrefHelper
    
      def self.read name
        first_named_role name, nil
      end

      def self.write name
        where(:name => name) || new(:name => name)
      end
    end
  end
end