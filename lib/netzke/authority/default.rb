module Netke
  module Authority
    module User
      attr_reader :auth_id, :clazz
      
      def initialize clazz, auth_id
        @clazz    = clazz
        @auth_id  = auth_id
      end      

      def find_all_below_current pref_name
        []
      end

      def self.find_all_lists_under model_name
        []
      end      
    end
  end
end
