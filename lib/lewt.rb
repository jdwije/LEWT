#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'yaml'
require 'optparse'

class Lewt
  def initialize()
    # Start by loading the local config files
    @clients = YAML.load_file(File.expand_path('../config/clients.yaml', __FILE__))
    @company = YAML.load_file(File.expand_path('../config/company.yaml', __FILE__))
    @settings = YAML.load_file(File.expand_path('../config/settings.yaml', __FILE__))
    # These are the available events in LEWT to which extensions can respond to
    # They are populated with HASH objects containing callback mappings that the
    # various extensions are requesting on init.
    @eventHandlers = {
      "initialize" => Array.new,
      "extract" => Array.new,
      "process" => Array.new,
      "render" => Array.new,
      "end" => Array.new
    }
    @extensions = Array.new
    
    # next load extensions THEN parse commands and fire init event hook.
    loadExtensions
    
    # parseCommands and fire init hook
    options = {}
    
    # comand passed to lewt from CL
    @command = ARGV[0]
    
    # argument supplied for `cmd' (if any). ignore option flags ie args that start with the `-' symbol
    @argument = ARGV[1] == nil || ARGV[1].match(/\-/i) ? nil : ARGV[1]
    
    parseInternalCommands
    
    OptionParser.new do |opts|
      
      init = fireInitEventHook( @command, @argument, opts, options )
      
      opts = init["options"]
      
      options = init["defaults"]
      
      # set LEWT core options after extensions to avoid over-riding them.
      opts.banner = "Usage: example.rb [options]"

    end.parse(ARGV)

    extract = fireEventHooks("extract", options)
    process = fireEventHooks("process", extract, options )
    render = fireEventHooks("render", process, options )
  end
  
  def parseInternalCommands
    if @command == "extend"      
      exit
    end
  end
  
  def fireInitEventHook ( cmd, arg, opts, defaults )
    @eventHandlers["initialize"].each do |handler|
      @opts = opts
      @defaults = defaults
      response = handler.call(cmd, arg, @opts, @defaults)
      @opts = response["options"]
      @defaults = response["defauts"]
    end
    return {
      "options" => opts,
      "defaults" => defaults
    }
  end

  def fireEventHooks( event, *data )
    algamation = nil
    if data then
      algamation = [];
      @eventHandlers["#{event}"].each do |handler|
        response = handler.call(*data)
        algamation = response + algamation
      end
    end
    return algamation
  end
  
  # fn loads all installed LEWT extensions by checking the ext_dir setting variable for available ruby files.
  def loadExtensions( directory = @settings["ext_dir"] || File.expand_path('../extensions', __FILE__) )
    Dir.foreach( directory ) do |file|
      next if (file =~ /\./) == 0
      if File.directory?(file)
        if Regexp.new('\.rb',Regexp::IGNORECASE).match(file) != nil
          load(directory + "/" + file)
          initializeExtension(file)
        end
      else
        # load file in dir named {dir_name}.rb
        load "#{directory}/#{file}/#{file}.rb"
        initializeExtension(file)
      end
    end
  end
  
  # fn basically anticipates a class name given its filepath and then call its registerHanders method.
  # Class names are transformed into UC words. '-' are interpreted as spaces in this conversion, and are 
  # striped afterwards to return something like 'invoice-renderer.rb' >>> 'InvoiceRenderer' ready for
  # evaluation.
  def initializeExtension ( file )
    classConvention = file.gsub("-", " ").split.map(&:capitalize).join(' ').gsub(" ","")
    exec = false
    if defined? eval( classConvention + "::registerHandlers" ) == true
      @extensions << classConvention
      return registerExtensionHandlers( eval ( classConvention + "::registerHandlers" ) )
    end
  end
  
  def registerExtensionHandlers ( request )
    # example request
    # #HASH {
    #  :initialize => classRef.method
    #  :process => classRef.method
    # }
    request.each do |event, handler|
      @eventHandlers["#{event}"] << handler
    end
  end
  
  def getClient( query ) 
    client = nil
    @clients.each do |c|
      buildQ = [ c["name"], c["alias"] ].join("|")
      regex = Regexp.new(buildQ, Regexp::IGNORECASE)
      if regex.match( query ) != nil
        client = c
      end
    end
    return client
  end

  def loadClientMatchData( query )
    requestedClients = Array.new
    if query == nil
      @clients.each do |client|
        requestedClients.push(client["name"])
        requestedClients.push(client["alias"])
      end
    else
      requestedClients = Array.new
      @clients.each do |client|
        query.split(",").each do |q|
          if [client["alias"], client["name"]].include?(q) == true 
            requestedClients.push(client["name"])
            requestedClients.push(client["alias"])
          end
        end
      end
    end
    return requestedClients
  end
end

Lewt.new
