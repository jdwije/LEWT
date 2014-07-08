#!/usr/bin/env ruby
require 'rubygems'
require 'date'
require 'yaml'
require 'optparse'
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

    options["start"] = DateTime.now - 8
    options["end"] = DateTime.now
    

    # Parse internal commands before extension commands & options to avoid any conflicts & to avoid extension invocation
    # in case a internal command is called.
    OptionParser.new do |opts|
      
      # LEWT's reserved option flags
      #
      # -x: what extractor[s] to use
      # -p: what processor[s] to use
      # -o: what renderer[s] to use
      # -t: target
      # -s: start target date
      # -e: end target date
      #
      # The user defined values for these options are readable by extensions at runtime.

      opts.on("-x", "--extractor [STRING]", String, "which extractor[s] to use") do |x|
        options["extractor"] = x
      end
      
      opts.on("-p", "--processor [STRING]", String, "which processor[s] to use") do |p|
        options["processor"] = p
      end
      
      opts.on("-o", "--renderer [STRING]", String, "which renderer[s] to use") do |o|
        options["renderer"] = o
      end

      opts.on("-t", "--target [STRING]", String, "what or whom are we targeting") do |t|
        # if no target is passed we are operating on all customers
        options["target"] = t || @customers
      end

      opts.on("-s", "--start [Date]", String, "start date") do |s|
        options["start"] = DateTime.parse(s)
      end

      opts.on("-e", "--end [Date]", String, "end date") do |e|
        options["end"] = DateTime.parse(e)
      end

      
      register_extension_options(opts,options)
      
      opts.banner = "Usage: lewt -x EXTRACTOR -p PROCESSOR -o RENDERER"
      
    end.parse!(ARGV)
    
    @options = options

    # parseInternalCommands( options )
  end

  def run_logic_loop
    extract = fireHooks("extract", @options)
    process = fireHooks("process",  @options, extract )
    render = fireHooks("render", @options, process )
  end
  
  # Passes an OptionsParser object to the extensions so they can set some custom CL option flags if they
  # so desire...
  def register_extension_options ( opts, defaults )
    @extensions.each do |e|
      if defined? e["ext"].register_options
        response = e["ext"].register_options(opts,defaults)
        opts = response["options"]
        defaults = response["defaults"]
      end
    end
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
        if defined? e["ext"].extract and e["cmd"].match(/#{options["extractor"]}/)
          algamation.concat e["ext"].extract(options)
        end
      end
    elsif hook == "process"
      @extensions.each do |e|
        if defined? e["ext"].process and e["cmd"].match(/#{options["processor"]}/)
           algamation.concat e["ext"].process(options, *data)
        end
      end
    elsif hook == "render"
      @extensions.each do |e|
        if defined? e["ext"].render and e["cmd"].match(/#{options["renderer"]}/)
           algamation.concat e["ext"].render(options, *data)
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

