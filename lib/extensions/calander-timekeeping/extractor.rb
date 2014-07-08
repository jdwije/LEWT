#!/usr/bin/ruby

# The Extractor class helps us extract data from iCal sources and converted it into a workable data structure.
# The Data Structure is defined in eds.rb or 'EventDataStructure' for short.
require 'icalendar'

class Extractor < LewtExtension
  
  attr_reader :data

  # inits the object and bubbles the result of extractCalenderData()
  def initialize( calendarPath, dateStart, dateEnd, targets ) 
    @data = LEWTBooks.new
    @calendarPath = calendarPath
    @dateStart  = dateStart 
    @dateEnd = dateEnd
    @targets = targets
    self.extractCalendarData
  end
  
  # returns the extracted calendar data
  def extractCalendarData
    calendars = Icalendar.parse( File.open( @calendarPath ) )
    calendars.each do |calendar|
      calendar.events.each do |e|
        if  self.isTargetDate(e.dtstart) == true && self.isTargetEvent( e ) != false
          row = LEWTLedger.new()
          # EventDataStructure.new( e.summary, e.dtstart, e.dtend, e.description )
          @data.add_row( row )
        end
      end
    end
  end
  
  # references the event title against clients for matching
  # billable events
  def isTargetEvent ( evt )
    eTitle = evt.summary
    match = false
    @matchingQueries.each do |query|

      re = /\A#{Regexp.escape(str)}\z/i # Match exactly this string, no substrings
      all = array.grep(re)              # Find all matching strings…
      any = array.any?{ |s| s =~ re }   #  …or see if any matching string is present

      if query == eTitle
        match = query
      end
    end
    return match
  end
  
  # checks whether event date is within target range
  def isTargetDate ( date ) 
    d = date.to_date
    check = false
    if d >= @dateStart.to_date && d <= @dateEnd.to_date
      check = true
    end
    return check
  end
end
