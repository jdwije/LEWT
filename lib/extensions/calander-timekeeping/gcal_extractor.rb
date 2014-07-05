#!/usr/bin/ruby
require 'google_calendar'

# This is a handler for extracting calDAV data from a server and converting it into the locally understood data structure.
class GCalExtractor < Extractor

  def initialize ( dStart, dEnd, matchingQueries, username, password, app_name )
    calendarPath = Google::Calendar.new(
                                        :username => username,
                                        :password => password,
                                        :app_name => app_name
                                        )
    super( calendarPath, dStart, dEnd, matchingQueries )
  end

 # references the event title against clients for matching
  # billable events
  def isTargetEvent ( evt )
    regex = Regexp.new( @matchingQueries.join("|"), Regexp::IGNORECASE )
    return regex.match(evt.title) != nil ? true : false;
  end
   
  # returns the extracted calendar data
  def extractCalendarData
    begin
      gConf = { 
        :max_results => 2500, 
        :order_by => 'starttime',
        :single_events => true
      }
      
      @calendarPath.find_events_in_range(@dateStart, @dateEnd + 1, gConf).each do |e|
        eStart = Time.parse( e.start_time )
        eEnd = Time.parse( e.end_time )
        if  self.isTargetDate( eStart ) == true && self.isTargetEvent( e ) != false
          row = LEWTLedger.new( eStart, eEnd, )
          @data.add_row(row)
        end
      end
    rescue
      raise Exception("Class #{self.class.name} failed to extract data from Google Calander.")
      exit
    end
  end

end



# run = GCalExtractor.new( DateTime.parse("01-05-2014"), DateTime.parse("01-06-2014"), ["TTS", "TipTop Select"])







