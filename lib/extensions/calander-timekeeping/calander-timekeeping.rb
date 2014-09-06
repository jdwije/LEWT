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
        :definition => "The calender extraction method to use, supports gCal, iCal, osx calender extraction. Defaults to gCal.",
        :type => String,
      },
      :suppress_cost => {
        :default => false,
        :definition => "Suppresses the cost calculation for the specified targets when calulating the hourly rates on extracted calender data. This is useful if you want to use this extension for tracking non-profit activites such as open-source project work as well as when you are being paid for these hours from another means (ie: milestones) and you just want to aggregate the hourly data into a report or something.",
        :type => String
      }
    }    
    super({:cmd => "calender", :options => options})
  end

  def extract( options )
    targetCustomers = self.loadClientMatchData( options["target"] )
    dStart =  options["start"]
    dEnd = options["end"]
    suppressTargets = options["suppress_cost"] == false ? false : self.loadClientMatchData(options["suppress_cost"])

    if options["ext_method"] == "iCal"
      extract = ICalExtractor.new( dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
    elsif options["ext_method"] == "gCal"
      extract = GCalExtractor.new(dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
    elsif options["ext_method"] == "apple"
      extract = AppleExtractor.new(dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
    end
    return extract.data
  end

end
