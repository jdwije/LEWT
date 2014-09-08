# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# =THE LEWT EXTENSION BASE CLASS
#
# This class provides some basic structuring for LEWT extensions 
# and additionally adds some meta features to extensions which 
# implement it in order to streamline development of LEWT
# extensions.

require "yaml"

class LewtExtension
  
  # LEWT Stash is the user configured stash path where all extensions, config file, templates etc are stored.
  attr_reader :lewt_stash, :lewt_settings, :customers, :enterprise, :options, :command_name
  
  # @@extensions is a registry shared between all extensions that impliment this class
  # containing there class names for invocation by the core system.
  @@lewt_extensions = Array.new
  @options = nil
  
  # This method is inoked by subclasses to initialise themselves within Lewt's extension registry.
  # ext_init [Hash]:: contains the keys <tt>:cmd</tt>, <tt>:options</tt> - which are the command name (String) and options (Hash) for the extension respectively.
  def initialize ( ext_init = { :cmd => "lewt_base_extension" } )
    # load core settings and check for user defined stash path
    path = File.expand_path( "../config/settings.yml", __FILE__ )
    core_settings = YAML.load_file( path )
    @lewt_stash = core_settings['stash_path'] || File.expand_path('../config', __FILE__)
    # Use namespaces wisely!
    @lewt_settings = YAML.load_file( lewt_stash + '/settings.yml' )
    @customers = YAML.load_file( lewt_stash + '/customers.yml' )
    @enterprise = YAML.load_file( lewt_stash + '/enterprise.yml' )
    @command_name = ext_init[:cmd]
    @options = ext_init[:options] || nil
    register_extension
  end

  # returns all registered extensions as an array of class names
  def lewt_extensions
    @@lewt_extensions
  end

  # This method mathes customers wth query strings provided by users in the CLI
  # query [String]:: A search string to query against.
  # suppress [String]:: A list of clients to exclude. Defaults to nil ie: none.
  def loadClientMatchData( query, suppress = nil )
    requestedClients = Array.new
    symbols_reg = /[,:-]/
    if query == nil
      @customers.each do |client|
        client_match = [ client["alias"], client["name"] ].join("|")
        if suppress == nil or client_match.match(suppress.gsub(symbols_reg,"|")) == nil
          requestedClients.push(client)
        else
          puts "ignored #{client["name"]}"
        end
      end
    else
      @customers.each do |client|
        client_match = [ client["alias"], client["name"] ].join("|")
        if client_match.match( query.gsub(symbols_reg,"|") ) != nil
          if suppress == nil or client_match.match(suppress.gsub(symbols_reg,"|")) == nil
            requestedClients.push(client)
          end
        end
      end
    end
    return requestedClients
  end

  protected
  
  # register the given extensions' class name with the system for later invocation
  def register_extension
    # only register subclass of this basclass
    if self.class != LewtExtension
      @@lewt_extensions << self.clone    
    end
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
  
end
