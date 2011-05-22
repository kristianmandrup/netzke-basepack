module Netke
  module Authority
    class Role < Default
      def initialize clazz, auth_id
        super
      end      
      
      def conditions
        {:role => auth_id}
      end
      
      def find_all_lists_under model_name
        role = Role.find(auth_id)
        role.users.inject([]) do |r, user|
          r += clazz.all(:user_id => user.id, :model_name => model_name)
        end
      end

      def find_all_below_current pref_name
        role = Role.find(auth_id)
        role.users.inject([]) do |r, user|
          r += all(:user_id => user.id, :name => pref_name)
        end
      end
    end
  end
end