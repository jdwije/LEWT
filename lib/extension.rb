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

# This module acts as a container for the LEWT namespace
module LEWT

  class Extension
    
    # LEWT Stash is the user configured stash path where all extensions, config file, templates etc are stored.
    attr_reader :lewt_stash, :lewt_settings, :customers, :enterprise, :options, :command_name

    # @@extensions is a registry shared between all extensions that impliment this class
    # containing there class names for invocation by the core system.
    @@lewt_extensions = Array.new
    @options = nil
    
    # This method is inoked by subclasses to initialise themselves within Lewt's extension registry.
    # ext_init [Hash]:: contains the keys <tt>:cmd</tt>, <tt>:options</tt> - which are the command name (String) and options (Hash) for the extension respectively.
    def initialize ( ext_init = { :cmd => "lewt_base_extension" } )
      core_settings = YAML.load_file( File.expand_path( '../config/settings.yml', __FILE__) )
      if File.exists? File.expand_path( '~/.lewt_settings', __FILE__)
        core_settings.merge! YAML.load_file( File.expand_path( '~/.lewt_settings', __FILE__) )
      end

      @lewt_stash = core_settings['lewt_stash'] || File.expand_path('../', __FILE__) + "/config/"
      load_lewt_settings()
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
    def get_matched_customers( query, suppress = nil )
      requestedClients = Array.new
      if query == nil
        @customers.each do |client|
          client_match = [ client["alias"], client["name"] ].join("|")
          if suppress == nil or client_match.match(suppress.gsub(Lewt::OPTION_DELIMITER_REGEX,"|")) == nil
            requestedClients.push(client)
          end
        end
      else
        @customers.each do |client|
          client_match = [ client["alias"], client["name"] ].join("|")
          if client_match.match( query.gsub(Lewt::OPTION_DELIMITER_REGEX,"|") ) != nil
            if suppress == nil or client_match.match(suppress.gsub(Lewt::OPTION_DELIMITER_REGEX,"|")) == nil
              requestedClients.push(client)
            end
          end
        end
      end
      return requestedClients
    end

    protected
    
    # This method loads the core LEWT settings files
    def load_lewt_settings 
      @lewt_settings = load_settings( "settings.yml")
      # Start by loading the local config files
      @customers = load_settings("customers.yml")
      @enterprise = load_settings("enterprise.yml")
    end

    # Writes a key/value pair to the settings file. This can then be accessed with lewt_settings[key] and is persisted
    # on the user's file system in a YAML settings file.
    # key [String]:: The key to write to the settings file
    # value:: The value to assign to this key.
    def write_settings ( file, key, value )
      settings = load_settings(file)
      settings[key] = value
      File.open( @lewt_stash + file, 'w') {|f| f.write settings.to_yaml } #Store
      load_lewt_settings() # reload settings vars
      return settings
    end


    
    # Formats the --save-name parameter if specified as a template into a string for usage with a File.write method.
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    # i [Integer]:: The current data array index to match the :targets option against
    def format_save_name(o, i)
      match_client = /\#alias/
      match_date = /\#date/
      t = o[:save_file].dup
      c = t.match match_client
      d = t.match match_date

      if c != nil
        clients = get_matched_customers(o[:target])
        client_alias = clients[i]["alias"]
        t.gsub! match_client, client_alias
      end

      if d != nil
        t.gsub! match_date, Date.today.to_s
      end
      
      return t
    end

    # Loads the specified settings file
    # property:: The variable you would like to assign the loaded YAML to
    # file [String]:: The settings file to load from lewt stash.
    def load_settings ( file )
      return YAML.load_file( @lewt_stash + file )
    end

    # register the given extensions' class name with the system for later invocation
    def register_extension
      # only register subclass of this basclass
      if self.class != LEWT::Extension
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

end
