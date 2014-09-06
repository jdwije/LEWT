#!/usr/bin/ruby
require 'google_calendar'

# This is a handler for extracting calDAV data from a server and converting it into the locally understood data structure.
class GCalExtractor < CalExtractor

  # Initialises as per its super-class plus the additional ```google``` parameter.
  # @param: google (Hash):: a hash containing your username, password, and google app name
  def initialize ( dStart, dEnd, targets, lewt_settings )
    uname = lewt_settings["gmail_username"]
    pass = lewt_settings["gmail_password"]
    app = lewt_settings["google_app_name"]
    @googleCalender = Google::Calendar.new(
                                           :username => uname,
                                           :password => pass,
                                           :app_name => app
                                           )
    super( dStart, dEnd, targets )
  end
  
  # This method does the actual google calender extract, comparing events to the requested paramters.
  # It manipulates the @data property of this object which is used by LEWT to gather the extracted data.
  def extractCalendarData
    gConf = { :max_results => 2500, :order_by => 'starttime', :single_events => true }
    @googleCalender.find_events_in_range(@dateStart, @dateEnd + 1, gConf).each do |e|
      eStart = Time.parse( e.start_time )
      eEnd = Time.parse( e.end_time )
      timeDiff = (eEnd - eStart).to_i / 60 / 60
      target = self.isTargetCustomer?(e.title)
      if  self.isTargetDate?( eStart ) == true && target != false
        row = LEWTLedger.new( eStart, eEnd, @category, target["name"], e.content, timeDiff, target["rate"] )
        @data.add_row(row)
      end
    end
  end

end
