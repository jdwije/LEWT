#!/usr/bin/ruby

# The Extractor class helps us extract data from iCal sources and converted it into a workable data structure.
# The Data Structure is defined in eds.rb or 'EventDataStructure' for short.

require 'icalendar'
load './lib/eds.rb'


class Extractor

  # inits the object and bubbles the result of extractCalenderData()
  def initialize( calendarPath, dateStart, dateEnd, matchingQueries ) 
    @data = Array.new
    @calendarPath = calendarPath
    @dateStart  = dateStart 
    @dateEnd = dateEnd
    @matchingQueries = matchingQueries
    self.extractCalendarData
  end
  
  def data
    return @data
  end
  
  # returns the extracted calendar data
  def extractCalendarData
    calendars = Icalendar.parse( File.open( @calendarPath ) )
    calendars.each do |calendar|
      calendar.events.each do |e|
        if  self.isTargetDate(e.dtstart) == true && self.isTargetEvent( e ) != false
          @data.push( EventDataStructure.new( e.summary, e.dtstart, e.dtend, e.description ) )
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




# little bit of script to allow usage from a command line
#filepath = ARGV[0]
#to = ARGV[1]
#from = ARGV[2]
#query = ARGV[3]

#if to != nil and from != nil
 # cli_mode = Extractor.new( filepath, DateTime.parse(to), DateTime.parse(from), query.split(",") )
  #puts "completed"
#end
