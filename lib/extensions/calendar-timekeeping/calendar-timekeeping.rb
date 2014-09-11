load File.expand_path('../extractor.rb', __FILE__)
load File.expand_path('../gcal_extractor.rb', __FILE__)
load File.expand_path('../ical_extractor.rb', __FILE__)
load File.expand_path('../apple_extractor.rb', __FILE__)


# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.



module LEWT

  # The Calander Timekeeping LEWT Extensions lets you extract timesheet data from your iCal, Google Calender, or OSX Calender
  # sources. In the process it transforms the data into a LEWTBook ready for processing.
  # 
  # In order for your calender events to be recognised as billable timesheet entries there are some naming conventions you must
  # observe.
  #
  # ===Conventions:
  # - The <tt>title</tt> of your event must contain a client name or alias reference in it.
  # - The <tt>description</tt> of your event will be pulled into the LEWTBook description column.
  include CalendarExtractors

  class CalendarTimekeeping < LEWT::Extension
    
    # Sets up this extension and registers its options.
    def initialize
      # set extension options
      options = {
        :ext_method => {
          :default => "gCal",
          :definition => "The calender extraction method to use, supports gCal, iCal, osx calender extraction. Defaults to gCal.",
          :type => String,
        },
        :suppress => {
          :definition => "Suppresses the cost calculation for the specified targets when calulating the hourly rates on extracted calender data. This is useful if you want to use this extension for tracking non-profit activites such as open-source project work as well as when you are being paid for these hours from another means (ie: milestones) and you just want to aggregate the hourly data into a report or something.",
          :type => String
        }
      }    
      super({:cmd => "calendar", :options => options})
    end

    # Extracts data from a given calender source based on what was passed in the <tt>options['ext_method']</tt> parameter.
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    # returns:: LEWTBook
    def extract( options )
      targetCustomers = self.loadClientMatchData( options[:target], options[:suppress] )
      dStart =  options[:start]
      dEnd = options[:end]
      suppressTargets = options[:suppress] == nil ? nil : self.loadClientMatchData(options[:suppress])
      if options[:ext_method] == "iCal"
        extract = CalendarExtractors::ICalExtractor.new( dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
      elsif options[:ext_method] == "gCal"
        extract = CalendarExtractors::GCalExtractor.new(dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
      elsif options[:ext_method] == "apple"
        extract = CalendarExtractors::AppleExtractor.new(dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
      end
      return extract.data
    end

  end

end
