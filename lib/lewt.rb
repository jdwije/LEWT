#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'yaml'
require 'optparse'
require_relative 'lewtopts.rb'
require_relative 'extension.rb'
require_relative 'lewt_ledger.rb'

class Lewt
  
  def initialize()
    core_settings = YAML.load_file( File.expand_path( '../config/settings.yml', __FILE__) )
    @lewt_stash = core_settings['lewt_stash'] || File.expand_path('../', __FILE__)
    @settings = YAML.load_file( @lewt_stash + '/config/settings.yml' )
    
    # Start by loading the local config files
    @customers = YAML.load_file(@lewt_stash + "/config/customers.yml")
    @enterprise = YAML.load_file(@lewt_stash + "/config/enterprise.yml")
    
    # Referenceall registered extension for later invocation
    @extensions = LewtExtension.new.lewt_extensions
    loadExtensions
    
    # Stores default options returned from extensions
    # and the LEWT defaults at large
    options = {}
    @command = ARGV[0]
    
    # argument supplied for `cmd' (if any). ignore option flags IE args that start with the `-' symbol
    @argument = ARGV[1] == nil || ARGV[1].match(/\-/i) ? nil : ARGV[1]
    
    @options = LewtOpts.new( @extensions )
    
    # parseInternalCommands( options )
  end

  def run_logic_loop
    extract = fireHooks("extract", @options)
    process = fireHooks("process", @options, extract )
    render = fireHooks("render", @options, process )
  end
  
  def parseInternalCommands( options )
    if @command == "extend"
      exit
    elsif @command == "extract"
      input = readSTDIN
      extract = fireEventHooks("extract", options)
      puts extract
    elsif @command == "process"
      input = readSTDIN
      process = fireEventHooks("process", input, options)
      puts process
    elsif @command == "render"
      input = readSTDIN
      render = fireEventHooks("render", input, options)
      puts render
    end
  end

  def readSTDIN
    data = ""
    while line = $stdin.gets
      data += line
    end
    return data
  end
  
  # Fire a hook with the given options and overloaded parameters.
  # Expected hooks are 'extract', 'process', 'render'.
  def fireHooks( hook, options, *data )
    algamation = Array.new
    if hook == "extract"
      @extensions.each do |e|
        if defined? e.extract and e.command_name.match(/#{options["extractor"]}/)
          algamation.concat e.extract(options)
        end
      end
    elsif hook == "process"
      @extensions.each do |e|
        if defined? e.process and e.command_name.match(/#{options["processor"]}/)
           algamation.concat e.process(options, *data)
        end
      end
    elsif hook == "render"
      @extensions.each do |e|
        if defined? e.render and e.command_name.match(/#{options["renderer"]}/)
           algamation.concat e.render(options, *data)
        end
      end
    end
    return algamation;
  end

  # fn loads all installed LEWT extensions by checking the ext_dir setting variable for available ruby files.
  def loadExtensions( directory = @lewt_stash + "/extensions" )
    Dir.foreach( directory ) do |file|
      next if (file =~ /\./) == 0
      if File.directory?(file)
        if Regexp.new('\.rb',Regexp::IGNORECASE).match(file) != nil
          load(directory + "/" + file)
          ext_object = initializeExtension(file)
        end
      else
        # load file in dir named {dir_name}.rb
        load "#{directory}/#{file}/#{file}.rb"
        ext_object = initializeExtension(file)
      end
    end
  end
  
  # fn basically anticipates a class name given its file path and then call its registerHanders method.
  # Class names are transformed into UC words. '-' are interpreted as spaces in this conversion, and are 
  # striped afterwards to return something like 'invoice-renderer.rb' >>> 'InvoiceRenderer' ready for
  # evaluation.
  def initializeExtension ( file )
    classConvention = file.gsub("-", " ").split.map(&:capitalize).join(' ').gsub(" ","")
    extInit = (classConvention + ".new").to_s
    extension = eval( extInit )
    # extension will be registered on init so just reference the last one
    return @extensions.last
  end
  
  # fn returns the desired customer given there name or alias.
  # A REGEXP query can be passed to this object i.e. "ACME|NovaCorp|..."
  # to match multiple customers.
  def getClient( query ) 
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

end

