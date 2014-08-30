load File.expand_path('../eventDataStructure.rb', __FILE__)
load File.expand_path('../extractor.rb', __FILE__)
load File.expand_path('../gcal_extractor.rb', __FILE__)

class CalanderTimekeeping < LewtExtension
  
  
  
  def initialize
    # set extension options
    options = {
      :calext_method => {
        :default => "gCal",
        :definition => "The default calender extraction method to use i.e. gCal, iCal...",
        :type => String,
        :short_flag => "-m"
      }
    }    
    super({:cmd => "calender", :option => options})
  end

  def extract( options )
    matchData = loadClientMatchData( options["target"] )
    dStart =  options["start"]
    dEnd = options["end"]

    if options["calext_method"] == nil || options["calext_method"] == "iCal"
      rawEvents = Extractor.new( lewt_settings["ical_filepath"], dStart, dEnd, matchData )
    elsif  options["calext_method"] == "gCal"
      rawEvents = GCalExtractor.new( dStart, dEnd, matchData, lewt_settings["gmail_username"], 
                                     lewt_settings["gmail_password"], lewt_settings["google_app_name"] )
    end
    return rawEvents.data
  end

  def getClient( query ) 
    client = nil
    customers.each do |c|
      buildQ = [ c["name"], c["alias"] ].join("|")
      regex = Regexp.new(buildQ, Regexp::IGNORECASE)
      if regex.match( query ) != nil
        client = c
      end
    end
    return client
  end

end
