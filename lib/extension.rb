##################################
## THE LEWT EXTENSION BASE CLASS ##
###################################
# --------------------------------
# This class provides some basic 
# structuring for LEWT extensions 
# and additionally adds some meta 
# features to extensions which 
# implement it in order to 
# streamline development of LEWT
# extensions.
#********************************
require "yaml"

class LewtExtension
  
  # LEWT Stash is the user configured stash path where all extensions, config file, templates etc are stored.
  attr_reader :lewt_stash, :lewt_settings, :customers, :enterprise
  
  # @@extensions is a registry shared between all extensions that impliment this class
  # containing there class names for invocation by the core system.
  @@lewt_extensions = Array.new

  def initialize
    # load core settings and check for user defined stash path
    path = File.expand_path( "../config/settings.yml", __FILE__ )
    core_settings = YAML.load_file( path )
    @lewt_stash = core_settings['stash_path'] || File.expand_path('../config', __FILE__)
    # Use namespaces wisely!
    @lewt_settings = YAML.load_file( lewt_stash + '/settings.yml' )
    @customers = YAML.load_file( lewt_stash + '/customers.yml' )
    @enterprise = YAML.load_file( lewt_stash + '/enterprise.yml' )
  end

  # returns all registered extensions as an array of class names
  def lewt_extensions
    @@lewt_extensions
  end
  
  protected
  
  # register the given extensions' class name with the system for later invocation
  # register the extensions CL name for user invocation
  def register_extension cmd_str
    @@lewt_extensions << { "ext" => self.clone, "cmd" => cmd_str }    
  end

  # This method is used by extensions to hook into the command line
  # call and set some user customisable at runtime.
  # It will be passed the options object from the ruby OptParse class.
  # def register_options opts end
  
  # The extract method can be implemented to extract data from custom sources.
  def extract 
    raise Exception "An extraction method is not defined by the #{self.class.name} class"
  end

  # The process method can be implemented to process extracted data.
  # It is passed the extracted data from the previous stage.
  def process extraced_data
    raise Exception "A processing method is not defined by the #{self.class.name} class"
  end

  # The render method can be implemented to create views for data.
  # It is passed the processed data from the previous stage.
  def render
    raise Exception "A rendering method is not defined by the #{self.class.name} class"
  end
  
  # This method mathes customers wth query strings provided by users in the CLI
  def loadClientMatchData( query )
    requestedClients = Array.new
    if query == nil
      customers.each do |client|
        requestedClients.push(client)
      end
    else
      customers.each do |client|
        query.split(",").each do |q|
          if [client["alias"], client["name"]].include?(q) == true 
            requestedClients.push(client)
          end
        end
      end
    end
    return requestedClients
  end

end
