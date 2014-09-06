load File.expand_path('../extractor.rb', __FILE__)
load File.expand_path('../gcal_extractor.rb', __FILE__)
load File.expand_path('../ical_extractor.rb', __FILE__)
load File.expand_path('../apple_extractor.rb', __FILE__)

class CalanderTimekeeping < LewtExtension
  
  def initialize
    # set extension options
    options = {
      :ext_method => {
        :default => "gCal",
        :definition => "The default calender extraction method to use i.e. gCal, iCal...",
        :type => String,
        :short_flag => "-m"
      }
    }    
    super({:cmd => "calender", :options => options})
  end

  def extract( options )
    targetCustomers = self.loadClientMatchData( options["target"] )
    dStart =  options["start"]
    dEnd = options["end"]
    if options["ext_method"] == "iCal"
      extract = ICalExtractor.new( dStart, dEnd, targetCustomers, lewt_settings )
    elsif options["ext_method"] == "gCal"
      extract = GCalExtractor.new(dStart, dEnd, targetCustomers, lewt_settings )
    elsif options["ext_method"] == "apple"
      extract = AppleExtractor.new(dStart, dEnd, targetCustomers, lewt_settings )
    end
    return extract.data
  end

end
