require 'acts_as_list_mongoid'

class NetzkePersistentArrayAutoModel 
  include Mongoid::Document
  include Netzke::Session # netzke session helpers

  acts_as_list

  default_scope :order => "position"
  cattr_accessor :config

  def self.all_columns
    all.map{ |c| c.attributes.reject{ |k,v| k == 'id' || k == 'position' } }
  end

  # Configuration
  def self.configure(config)
    self.config = config

    if NetzkePreference.where(:name => "netzke_persistent_array_refresh_token").first.try(:value) != refresh_token # || !connection.table_exists?(table_name)
      rebuild_table
    end

    NetzkePreference.find_or_create_by_name("netzke_persistent_array_refresh_token").update_attribute(:value, refresh_token)
  end

  # Not needed for a Document Store (since flexible schema)
  # Only needed for Relational DB (since fixed schema)
  # def self.rebuild_table#(config)
  #   collection.remove
  #   
    # create the table with the fields
    # self.connection.create_table(table_name) do |t|
    #   config[:columns].each do |c|
    #     c = c.dup # to make next line shorter
    #     t.column c.delete(:name), c.delete(:type), c
    #   end
    # end
  # 
  #   self.reset_column_information
  # 
  #   # self.create config[:initial_data]
  #   self.replace_data(config[:initial_data])
  # end

  def self.replace_data(data)
    # only select those attributes that were provided to us as columns. The rest is ignored.
    column_names = config[:columns].map{ |c| c[:name] }
    clean_data = data.collect{ |c| c.reject{ |k,v| !column_names.include?(k.to_s) } }
    delete_all
    create(clean_data).save
  end

  private

  def self.refresh_token
    @@refresh_token ||= begin      
      config[:owner] + (masqueraded_user || masqueraded_role || masqueraded_world || netzke_user).to_s
    end
  end
  
  def self.session
    Netzke::Base.session
  end
end