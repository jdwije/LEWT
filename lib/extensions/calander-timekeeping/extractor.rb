#!/usr/bin/ruby

# The CalExtractor class acts as base class for various calender extraction interfaces such as google, ical, apple, etc.
# It provides some convenience methods that are useful across the various implementations.
class CalExtractor < LewtExtension
  
  attr_reader :data

  # Initialises this class. This method should be invoked by sub-classes with 'super()'. It invokes
  # ```extractCalenderData``` on the sub-classes behalf when called...
  # @param dateStart (String):: a human readable date as a string for the start time period
  # @param dateEnd (String):: a human readable date as a string for the end time period
  # @param targets (Hash):: a hash containing all the targets returned by the LewtExtension.loadClientMatchData() method
  def initialize( dateStart, dateEnd, targets ) 
    @data = LEWTBook.new
    @dateStart  = dateStart.to_date 
    @dateEnd = dateEnd.to_date
    @targets = targets
    @category = "Hourly Income"
    self.extractCalendarData
  end
  
  # Returns the extracted calendar data. Must be implimented by subclasses.
  def extractCalendarData
  end
  
  # Matches a search string against customer names/aliases
  # @param: evtSearch (String):: a string to search against (such as the title of an event)
  # @returns: (Boolean|Hash): false when no match found or the target customer details (as a hash) when matched
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
  # @param: date (Date):: the date to check against
  # @return: (Boolean):: true/false operation status
  def isTargetDate? ( date ) 
    d = date
    check = false
    if d >= @dateStart && d <= @dateEnd
      check = true
    end
    return check
  end

end
