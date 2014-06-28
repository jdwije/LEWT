#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'yaml'
require 'optparse'
load 'extension.rb'

class Lewt
  
  def initialize()
    core_settings = YAML.load_file( File.expand_path( '../config/settings.yml', __FILE__) )
    @stash_path = core_settings['stash_path'] || File.expand_path('../', __FILE__)
    @settings = YAML.load_file( @stash_path + '/config/settings.yml' )
    
    # Start by loading the local config files
    @clients = YAML.load_file(@stash_path + "/config/clients.yml")
    @company = YAML.load_file(@stash_path + "/config/company.yml")

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

    # Array to store our extension class names for later invokation. Then do load.
    @extensions = Array.new
    loadExtensions

    # Stores default options returned from extensions
    # and the LEWT defaults at large
    options = {}
    @command = ARGV[0]

    # argument supplied for `cmd' (if any). ignore option flags IE args that start with the `-' symbol
    @argument = ARGV[1] == nil || ARGV[1].match(/\-/i) ? nil : ARGV[1]
    
    # Parse internal commands before extension commands & options to avoid any conflicts & to avoid extension invocation
    # in case a internal command is called.

    
    OptionParser.new do |opts|
      
      init = fireInitEventHook( @command, @argument, opts, options )
      
      opts = init["options"]
      
      options = init["defaults"]
      
      # set LEWT core options after extensions to avoid over-riding them.
      opts.banner = "Usage: example.rb [options]"

    end.parse(ARGV)

    parseInternalCommands( options )

    extract = fireEventHooks("extract", options)
    process = fireEventHooks("process", extract, options )
    render = fireEventHooks("render", process, options )
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
  def loadExtensions( directory = @stash_path + "/extensions" )
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
  
  # fn basically anticipates a class name given its file path and then call its registerHanders method.
  # Class names are transformed into UC words. '-' are interpreted as spaces in this conversion, and are 
  # striped afterwards to return something like 'invoice-renderer.rb' >>> 'InvoiceRenderer' ready for
  # evaluation.
  def initializeExtension ( file )
    classConvention = file.gsub("-", " ").split.map(&:capitalize).join(' ').gsub(" ","")
    extInit = (classConvention + ".new").to_s
    extension = eval( extInit )
     @extensions << extension
    return registerExtensionHandlers( @extensions.last::registerHandlers )
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

