#!/usr/bin/ruby
require 'google_calendar'

# This is a handler for extracting calDAV data from a server and converting it into the locally understood data structure.
class GCalExtractor < Extractor

  def initialize ( dStart, dEnd, targets, username, password, app_name )
    calendarPath = Google::Calendar.new(
                                        :username => username,
                                        :password => password,
                                        :app_name => app_name
                                        )
    
    super( calendarPath, dStart, dEnd, targets )
  end
  
  # references the event title against clients for matching
  # billable events
  def isTargetEvent ( evt, customer )
    reg = [ customer['alias'], customer['name'] ]
    regex = Regexp.new( reg.join("|"), Regexp::IGNORECASE )
    return regex.match(evt.title) != nil ? true : false;
  end
   
  # returns the extracted calendar data
  def extractCalendarData
    gConf = { 
      :max_results => 2500, 
      :order_by => 'starttime',
      :single_events => true
    }
    @calendarPath.find_events_in_range(@dateStart, @dateEnd + 1, gConf).each do |e|
      eStart = Time.parse( e.start_time )
      eEnd = Time.parse( e.end_time )
      timeDiff = (eEnd - eStart).to_i / 60 / 60
      @targets.each do |t|
        if  self.isTargetDate( eStart ) == true && self.isTargetEvent( e, t ) != false
          row = LEWTLedger.new( eStart, eEnd, 'Income', t["name"], e.content, timeDiff, t["rate"] )
          @data.add_row(row)
        end
      end
    end
  end

end









