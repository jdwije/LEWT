# require 'google/api_client'



# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.


module CalendarExtractors

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
    def initialize ( dStart, dEnd, targetCustomers, lewt_settings, suppressTargets )
      @client = Google::APIClient.new(:application_name => 'LEWT Calendar Extractor',
        :application_version => '1.0.0')

      flow = Google::APIClient::InstalledAppFlow.new(
                                                     :client_id => "1065725172516-4f4qlo8ghrs92saau9jls792a60cui9e.apps.googleusercontent.com",
                                                     :client_secret => "PqRoz_ewVJOVZDuH8ITFbSQv",
                                                     :scope => ['https://www.googleapis.com/auth/calendar.readonly']
                                                     )
      
      @calendar = client.discovered_api('calendar', 'v3')
      
      client.authorization = flow.authorize(@calendar)
      
      super( dStart, dEnd, targetCustomers )
    end
    
    # This method does the actual google calender extract, comparing events to the requested paramters.
    # It manipulates the @data property of this object which is used by LEWT to gather the extracted data.
    def extractCalendarData
      response = @client.execute(
                              :api_method => @calendar.events.list,
                              :parameters => { 'calendarId' => lewt_settings["google_calendar_id"] }
                              )
      if response.data?
        response.data.items.each do |i|
          eStart = Time.parse( i.start.dateTime )
          eEnd = Time.parse( i.end.dateTime )
          timeDiff = (eEnd - eStart)/60/60
          target = self.isTargetCustomer?(i.summary)
          if  self.isTargetDate?( eStart ) == true && target != false
            row = LEWT::LEWTLedger.new({
                                         :date_start => eStart, 
                                         :date_end => eEnd, 
                                         :category => @category, 
                                         :entity => target["name"], 
                                         :description => e.content, 
                                         :quantity => timeDiff, 
                                         :unit_cost => target["rate"]
                                       })
            @data.push(row) 
          end
        end
      end
    end
  end
end
