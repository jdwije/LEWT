#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'yaml'
require 'optparse'
require_relative 'lewtopts.rb'
require_relative 'extension.rb'
require_relative 'lewt_book.rb'
require_relative 'lewt_ledger.rb'


# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# This module acts as a container for the LEWT namespace
module LEWT
  
  # The Lewt class contains the major functionality of this program.
  # It handles loading all extensions, gathering the results and passing options ariound the place.
  # It also works quite closely with the LewtExtension and LewtOpts classes.
  class Lewt

    # Can be used to split strings passed to lewt through CL optios ie: 
    #  "acme,wayne_corp".split(CLIENT_SPLIT_REGEX) # get each argument for client mathching
    OPTION_DELIMITER_REGEX = /[,+:]/

    # This matches symbols passed thought command ie: -p meta-stat => meta_stat
    OPTION_SYMBOL_REGEX = /\W/  
    
    def initialize( library_options = nil )
      core_settings = YAML.load_file( File.expand_path( '../config/settings.yml', __FILE__) )
      if File.exists? File.expand_path( '~/.lewt_settings', __FILE__)
        core_settings.merge! YAML.load_file( File.expand_path( '~/.lewt_settings', __FILE__) )
      end

      @lewt_stash = core_settings['lewt_stash'] || File.expand_path('../', __FILE__) + "/config/"
      @settings = YAML.load_file( @lewt_stash + 'settings.yml' )
      
      # Start by loading the local config files
      @customers = YAML.load_file(@lewt_stash + "customers.yml")
      @enterprise = YAML.load_file(@lewt_stash + "enterprise.yml")
      
      # Referenceall registered extension for later invocation
      @extensions = LEWT::Extension.new.lewt_extensions


      # Load core extensions
      load_extensions( File.expand_path('../extensions', __FILE__) )

      if core_settings.has_key?("lewt_stash")
        # load user defined extesnions
        load_extensions
      end

      # Stores default options returned from extensions
      # and the LEWT defaults at large
      options = {}
      @command = ARGV[0]
      
      # argument supplied for `cmd' (if any). ignore option flags IE args that start with the `-' symbol
      @argument = ARGV[1] == nil || ARGV[1].match(/\-/i) ? nil : ARGV[1]
      
      @options = LewtOpts.new( @extensions, library_options  )
      
      parse_internal_commands
    end

    # Runs the extract render process loop
    def run
      extract = fire_hooks("extract", @options)
      process = fire_hooks("process", @options, extract )
      render = fire_hooks("render", @options, process )
    end
    

    # fn returns the desired customer given there name or alias.
    # A REGEXP query can be passed to this object i.e. "ACME|NovaCorp|..."
    # to match multiple customers.
    # query [String]:: The query to search against.
    def get_client( query ) 
      client = nil
      @customers.each do |c|
        buildQ = [ c["name"], c["alias"] ].join("|")
        regex = Regexp.new(buildQ, Regexp::IGNORECASE)
        if regex.match( query ) != nil
          client = c
        end
      end
      return client
    end
    
    protected 

    # Parses lewsts intenral commands. If none have been invoked it simple returns.
    def parse_internal_commands
      return if @command == nil
      # raise argument error if command invoked without argument
      if @argument == nil and @command != nil
        puts @command
        raise ArgumentError, "Class #{self.class.name} requires an argument t be supplied with a command" 
      end
      
      if @command.match(/pipe/)
        # pipe stdin into fire_hook(@argument) event
        data = Psych.load(read_stdin)
        if data != nil
          hook_process(@argument, data)
        else
          raise ArgumentError, "could not parse STDIN pipe as YAML data."
        end
        exit
      end

    end
    
    # Fire the logic loop from the specified hook onwards. Used when piping data in from CL
    # hook [Sting]:: extract, process, or render
    # data:: The data to pass to fire_hooks
    def hook_process (hook, data)
      case hook
      when "extract"
        extracted_data = fire_hooks("extract",@options,data)
        hook_process("process", extracted_data)
      when "process"
        processed_data = fire_hooks("process",@options,data)
        hook_process("render",processed_data)
      when "render"
        render_data = fire_hooks("render",@options,data)
      else
        raise ArugmentError, "#{self.class.name}.hook_process requires the start hook to be either render or process"
      end
    end

    # reads input from standard INPUT
    def read_stdin
      data = ""
      while line = $stdin.gets
        data += line
      end
      return data
    end
    
    # Fire a hook with the given options and overloaded parameters.
    # hook [String]:: Expected hooks are 'extract', 'process', 'render'.
    # options [Hash]:: The options gathered from using LewtOpts
    # data [Mixed]:: The data to pass to the extensions.
    def fire_hooks( hook, options, *data )
      algamation = Array.new
      @extensions.each { |e|
        ## filter hooks
        filter_regex = /#{options[hook.to_sym].gsub(",","|")}/
        if e.methods.include?(hook.to_sym) and e.command_name.match(filter_regex)
          case hook
          when "extract"
            algamation.concat e.extract(options)
          when "process"
            processed = e.process(options, *data)
            if processed.kind_of? Array 
              algamation.concat processed
            else
              algamation.push processed
            end
          when "render"
            algamation.concat e.render(options, *data)
            # dump render output to console of option specified.
            puts algamation if options[:dump_output] == true
          end
        end
      }
      return algamation;
    end

    # Loads all installed LEWT extensions by checking the ext_dir setting variable for available ruby files.
    # directory [String]:: The path where to look for extensions as a string.
    def load_extensions( directory = @lewt_stash + "extensions" )
      raise Exception, "Directory does not exist: #{directory}" if !Dir.exists?(directory)

      Dir.foreach( directory ) do |file|
        next if (file =~ /\./) == 0
        # Cannot match with File.directory?(file) due to how ruby performs
        # this test internaly when script is called from another dir.
        # Therefor some REGEX will be used to match the .rb file extension instead...
        if file.match(/\.rb/) != nil
          load(directory + "/" + file)
          ext_object = initialize_extension( file )
        else
          # is a directory
          # load file in dir named {dir_name}.rb
          load "#{directory}/#{file}/#{file}.rb"
          ext_object = initialize_extension(file)
        end
      end

      # load extensions packaged as GEMS
      if @settings['gem_loads'] != nil
        @settings['gem_loads'].split(Lewt::OPTION_DELIMITER_REGEX).each do |g|
          match = g.split("/")
          ext_object = initialize_gem(match[0], match[1])
        end
      end
      
    end
    
    # This method initialised a gem as specifed in your settings file.
    # gem_require [String]:: The gem require path as a string
    # gem_class [String]:: The gem class name for initialisation
    def initialize_gem( gem_require, gem_class )
      require gem_require
      extension = eval( gem_class + ".new")
      return @extensions.last
    end

    # fn basically anticipates a class name given its file path and then call its registerHanders method.
    # Class names are transformed into UC words. '-' are interpreted as spaces in this conversion, and are 
    # striped afterwards to return something like 'invoice-renderer.rb' >>> 'InvoiceRenderer' ready for
    # evaluation.
    # file [String]:: The file name as a string
    def initialize_extension ( file )
      classConvention = file.gsub("-", " ").split.map(&:capitalize).join(' ').gsub(" ","").gsub(".rb","")
      extInit = ("LEWT::" + classConvention + ".new").to_s
      extension = eval( extInit )
      # extension will be registered on init so just reference the last one
      return @extensions.last
    end
    
  end

end
