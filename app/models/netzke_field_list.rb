# TODO: clean up, document and test
class NetzkeFieldList 
  include Mongoid::Document

  # http://mongoid.org/docs/relations/referenced/1-n.html  
  belongs_to :user
  belongs_to :role
  belongs_to :parent, :class_name => "NetzkeFieldList"

  has_many :children, :class_name => "NetzkeFieldList", :foreign_key => "parent_id"


  def self.update_fields(owner_id, attrs_hash)
    find_all_below_current_authority_level(owner_id).each do |list|
      list.update_attrs(attrs_hash)
    end
  end

  # Updates attributes in the list
  def update_attrs(attrs_hash)
    list = ActiveSupport::JSON.decode(self.value)
    list.each do |field|
      field.merge!(attrs_hash[field["name"]]) if attrs_hash[field["name"]]
    end
    update_attribute(:value, list.to_json)
  end

  def append_attr(attr_hash)
    list = ActiveSupport::JSON.decode(self.value)
    list << attr_hash
    update_attribute(:value, list.to_json)
  end

  def self.find_all_below_current_authority_level(pref_name)
    authority_level, authority_id = Netzke::Base.authority_level
    case authority_level
    when :world
      all(:name => pref_name)
    when :role
      role = Role.find(authority_id)
      role.users.inject([]) do |r, user|
        r += all(:user_id => user.id, :name => pref_name)
      end
    else
      []
    end
  end

  def self.find_all_lists_under_current_authority(model_name)
    authority_level, authority_id = Netzke::Base.authority_level
    case authority_level
    when :world
      all(:model_name => model_name)
    when :role
      role = Role.find(authority_id)
      role.users.inject([]) do |r, user|
        r += all(:user_id => user.id, :model_name => model_name)
      end
    when :user
      all(:user_id => authority_id, :model_name => model_name)
    when :self
      all(:user_id => authority_id, :model_name => model_name)
    else
      []
    end

  end


  # Replaces the list with the data - only for the list found for the current authority.
  # If the list is not found, it's created.
  def self.update_list_for_current_authority(pref_name, data, model_name = nil)
    pref = find_or_create_pref_to_read(pref_name)
    pref.value = data.to_json
    pref.model_name = model_name
    pref.save!
  end


  # If the <tt>model</tt> param is provided, then this preference will be assigned a parent preference
  # that configures the attributes for that model. This way we can track all preferences related to a model.
  def self.write_list(name, list, model = nil)
    pref_to_store_the_list = pref_to_write(name)
    pref_to_store_the_list.try(:update_attribute, :value, list.to_json)

    # link this preference to the parent that contains default attributes for the same model
    if model
      model_level_attrs_pref = pref_to_read("#{model.tableize}_model_attrs")
      model_level_attrs_pref.children << pref_to_store_the_list if model_level_attrs_pref && pref_to_store_the_list
    end
  end

  def self.read_list(name)
    json_encoded_value = pref_to_read(name).try(:value)
    ActiveSupport::JSON.decode(json_encoded_value).map(&:symbolize_keys) if json_encoded_value
  end

  # Read model-level attrs
  # def self.read_attrs_for_model(model_name)
  #   read_list(model_name)
  #   # read_list("#{model.tableize}_model_attrs")
  # end

  # Write model-level attrs
  # def self.write_attrs_for_model(model_name, data)
  #   # write_list("#{model_name.tableize}_model_attrs", data)
  #   write_list(model_name, data)
  # end

  # Options:
  # :attr - attribute to propagate. If not specified, all attrs found in configuration for the model
  # will be propagated.
  def self.update_children_on_attr(model, options = {})
    attr_name = options[:attr].try(:to_s)

    parent_pref = pref_to_read("#{model.tableize}_model_attrs")

    if parent_pref
      parent_list = ActiveSupport::JSON.decode(parent_pref.value)
      parent_pref.children.each do |ch|
        child_list = ActiveSupport::JSON.decode(ch.value)

        if attr_name
          # propagate a certain attribute
          propagate_attr(attr_name, parent_list, child_list)
        else
          # propagate all attributes found in parent
          all_attrs = parent_list.first.try(:keys)
          all_attrs && all_attrs.each{ |attr_name| propagate_attr(attr_name, parent_list, child_list) }
        end

        ch.update_attribute(:value, child_list.to_json)
      end
    end
  end

  # meta_attrs:
  #   {"city"=>{"included"=>true}, "building_number"=>{"default_value"=>100}}
  def self.update_children(model, meta_attrs)
    parent_pref = pref_to_read("#{model.tableize}_model_attrs")


    if parent_pref
      parent_pref.children.each do |ch|
        child_list = ActiveSupport::JSON.decode(ch.value)

        meta_attrs.each_pair do |k,v|
          child_list.detect{ |child_attr| child_attr["name"] == k }.try(:merge!, v)
        end

        ch.update_attribute(:value, child_list.to_json)
      end
    end
  end

  private

    def self.propagate_attr(attr_name, src_list, dest_list)
      for src_field in src_list
        dest_field = dest_list.detect{ |df| df["name"] == src_field["name"] }
        dest_field[attr_name] = src_field[attr_name] if dest_field && src_field[attr_name]
      end
    end

    # Overwrite pref_to_read, pref_to_write methods, and find_all_for_component if you want a different way of
    # identifying the proper preference based on your own authorization strategy.
    #
    # The default strategy is:
    #   1) if no masq_user or masq_role defined
    #     pref_to_read will search for the preference for user first, then for user's role
    #     pref_to_write will always find or create a preference for the current user (never for its role)
    #   2) if masq_user or masq_role is defined
    #     pref_to_read and pref_to_write will always take the masquerade into account, e.g. reads/writes will go to
    #     the user/role specified
    #
    def self.pref_to_read(name)
      "Netzke::#{user_type.camelize}".constantize.read name
    end

    def self.user_type
      res = [:masqueraded_user, :masqueraded_role, :masqueraded_world, :netzke_user].select {|name| send(name) }
      res ||= :default_user
    end
      

    def self.find_or_create_pref_to_read(name)
      extend_attrs_for_current_authority(:name => name)
      where(:name => name) || new(:name => name)
    end

    def self.extend_attrs_for_current_authority(hsh)
      authority_level, authority_id = Netzke::Base.authority_level
      case authority_level
      when :world
        hsh.merge!(:role_id => 0)
      when :role
        hsh.merge!(:role_id => authority_id)
      when :user, :self
        hsh.merge!(:user_id => authority_id)
      end
    end

    def self.pref_to_write name
      "Netzke::#{user_type.camelize}".constantize.write name
    end
end
