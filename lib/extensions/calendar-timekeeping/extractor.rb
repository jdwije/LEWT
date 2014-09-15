# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.



module CalendarExtractors

  # The CalExtractor class acts as base class for various calender extraction interfaces such as GCalExtractor, ICalExtractor
  # AppleExtractor. It provides some convenience methods that are useful across the various implementations.
  class CalExtractor < LEWT::Extension
    
    attr_reader :data

    # Initialises this class. This method should be invoked by sub-classes with <tt>super()</tt>. It invokes
    # <tt>extractCalenderData</tt> on the sub-classes behalf when called...
    # dateStart [String]:: a human readable date as a string for the start time period
    # dateEnd [String]:: a human readable date as a string for the end time period
    # targets [Hash]:: a hash containing all the targets returned by the LewtExtension.get_matched_customers() method
    def initialize( dateStart, dateEnd, targets )
      @data = LEWT::LEWTBook.new
      @dateStart  = Date.parse dateStart.to_s 
      @dateEnd = Date.parse dateEnd.to_s
      @targets = targets
      @category = "Hourly Income"
      self.extractCalendarData
    end
    
    # Returns the extracted calendar data. Must be implimented by subclasses.
    def extractCalendarData
      
    end
    
    # Matches a search string against customer names/aliases
    # evtSearch [String]:: a string to search against such as the title of an event
    # returns:: false when no match found or the target customer details (as a hash) when matched
    def isTargetCustomer? ( evtSearch )
      match = false
      @targets.each do |t|
        reg = [ t['alias'], t['name'] ]
        regex = Regexp.new( reg.join("|"), Regexp::IGNORECASE )
        match = regex.match(evtSearch) != nil ? t : false;
        break if match != false
      end
      return match
    end
    
    # Checks whether an event date is within target range
    # date [Date]:: the date to check against
    # return:: Boolean true/false operation status
    def isTargetDate? ( date ) 
      d = DateTime.parse(date.to_s)
      check = false
      if d >= @dateStart && d <= @dateEnd
        check = true
      end
      return check
    end

  end

end
