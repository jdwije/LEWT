require 'google_calendar'

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# Extracts data from a Google Calender source.
#
# === Setup
# It is required that you have a Google App setup with your account to allow for API access to your data. Then 
# add the following keys to your settings file.
#
# gmail_username:: The username for your google application.
# gmail_password:: The password associated with this username.
# gmail_app_name:: The name of the application you created.
# 
class GCalExtractor < CalExtractor

  # Sets up this extension
  def initialize ( dStart, dEnd, targets, lewt_settings, suppressTargets )
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
      timeDiff = (eEnd - eStart) / 60 / 60
      target = self.isTargetCustomer?(e.title)
      if  self.isTargetDate?( eStart ) == true && target != false
        row = LEWTLedger.new( eStart, eEnd, @category, target["name"], e.content, timeDiff, target["rate"] )
        @data.push(row)
      end
    end
  end

end
