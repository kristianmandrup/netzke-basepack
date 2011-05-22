module Netke
  module Authority
    module Self < Default

      def initialize clazz, auth_id
        super
      end

      def conditions
        {:user => auth_id}
      end

      def self.find_all_lists_under model_name)      
        clazz.all(:user_id => auth_id, :model_name => model_name)
      end      
    end
  end
end
