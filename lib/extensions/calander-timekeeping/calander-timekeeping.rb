load File.expand_path('../eventDataStructure.rb', __FILE__)
load File.expand_path('../extractor.rb', __FILE__)
load File.expand_path('../gcal_extractor.rb', __FILE__)


class CalanderTimekeeping

  def initialize
    @clients = YAML.load_file( File.expand_path('../../../clients.yaml', __FILE__) )
  end

  def self.registerHandlers
    return {
      "extract" => method(:doExtract)
    }
  end

 def self.doExtract(args)
    options = {}
    options["start"] = DateTime.now - 7
    options["end"] = DateTime.now
    options["method"] = "gCal"
    
    OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options["verbose"] = v
      end

      opts.on("-t", "--target [STRING]", String, "Execute on target client") do |t|
        options["target"] = t
      end

      opts.on("-s", "--date-start [DATE]", String, "Start date of billing period") do |sD|
        options["start"] = DateTime.parse(sD)
      end

      opts.on("-e", "--date-end [DATE]", String, "End date of billing period") do |eD|
        options["end"] = DateTime.parse(eD)
      end

      opts.on("-m", "--method [STRING]", String, "End date of billing periodWhat extractor to use") do |m|
        options["method"] = m
      end      
    end.parse(args)
    
   command = args[0]
   target = options["target"]
   @clients = YAML.load_file( File.expand_path('../../../config/clients.yaml', __FILE__) )
   
    if command == nil || command == "all"
      puts "no command given to lewt. invoke with <cmd> eg: lewt invoice 'client_alias'"
    elsif command == "invoice"
      matchData = self.loadClientMatchData(target)
      dStart =  options["start"]
      dEnd = options["end"]

      if options["method"] == nil || options["method"] == "iCal"
        rawEvents = Extractor.new( @settings["ical_filepath"], dStart, dEnd, matchData )
      elsif  options["method"] == "gCal"
        rawEvents = GCalExtractor.new( dStart, dEnd, matchData )
      end
      # bills = Billing.new( rawEvents.data, self.getClient(target)  )
    end
   return rawEvents.data
 end


  def self.getClient( query ) 
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

  def self.loadClientMatchData( query )
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
