load File.expand_path('../eventDataStructure.rb', __FILE__)
load File.expand_path('../extractor.rb', __FILE__)
load File.expand_path('../gcal_extractor.rb', __FILE__)

class CalanderTimekeeping < LewtExtension

  def initialize
    super()
    @clients = YAML.load_file( stash_path + '/clients.yml' )
  end

  def registerHandlers
    return {
      "extract" => method(:doExtract),
      "initialize" => method(:setOptions)
    }
  end

  def setOptions(cmd, arg, opts, options)
    # set default command line options if required
    options["start"] = DateTime.now - 8
    options["end"] = DateTime.now
    options["method"] = "gCal"
    
    # set instance command & argument values
    @cmd = cmd
    @arg = arg

    opts.on("-s", "--date-start [DATE]", String, "Start date of billing period") do |sD|
      options["start"] = DateTime.parse(sD)
    end

    opts.on("-e", "--date-end [DATE]", String, "End date of billing period") do |eD|
      options["end"] = DateTime.parse(eD)
    end

    opts.on("-x", "--extractor [STRING]", String, "What extractor to use") do |m|
      options["method"] = m
    end      

    
    return {
      "options" => opts,
      "defaults" => options
    }
  end

 def doExtract(options)
    if @cmd == nil || @cmd == "all"
      puts "no command given to lewt. invoke with <cmd> eg: lewt invoice 'client_alias'"
    elsif @cmd == "invoice"
      matchData = loadClientMatchData(@arg)
      dStart =  options["start"]
      dEnd = options["end"]
      if options["method"] == nil || options["method"] == "iCal"
        rawEvents = Extractor.new( @settings["ical_filepath"], dStart, dEnd, matchData )
      elsif  options["method"] == "gCal"
        rawEvents = GCalExtractor.new( dStart, dEnd, matchData )
      end
    end
   return rawEvents.data
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
