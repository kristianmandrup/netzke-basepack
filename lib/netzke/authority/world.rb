module Netke
  module Authority
    module World < Default

      def initialize clazz, auth_id
        super
      end

      def conditions
        {:role => nil}
      end
      
      def find_all_lists_under model_name
        clazz.all(:model_name => model_name)
      end
      
      def find_all_below_current pref_name
        clazz.all(:name => pref_name)
      end
    end
  end
end