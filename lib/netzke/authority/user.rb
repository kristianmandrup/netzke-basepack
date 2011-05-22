module Netke
  module Authority
    module User < Default
      
      def initialize clazz, auth_id
        super
      end      

      def conditions
        {:user => auth_id}
      end

      def find_all_lists_under model_name
        all(:user_id => auth_id, :model_name => model_name)
      end      
    end
  end
end