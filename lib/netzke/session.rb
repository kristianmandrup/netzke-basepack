module Netzke
  module Session
    def session 
      Netzke::Base.session
    end

    def netzke_user
      session[:netzke_user_id]
    end
    alias_method :netzke_user?, :netzke_user

    def masqueraded_user
      session[:masq_user]
    end
    alias_method :masqueraded_user?, :masqueraded_user

    def masqueraded_role
      session[:masq_role]
    end
    alias_method :masqueraded_role?, :masqueraded_role

    def masqueraded_world
      session[:masq_world]
    end
    alias_method :masqueraded_world?, :masqueraded_world
  end
end