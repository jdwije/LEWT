require 'icalendar'

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# This class handles extraction from iCal sources.
#
# ===Usage:
# - add the key <tt>ical_filepath</tt> to you settings file corresponding to the filepath of the ical file you wish to have parsed.
#
class ICalExtractor < CalExtractor

  # Initialises the object and calls the parent class' super() method.
  def initialize( dateStart, dateEnd, targets, lewt_settings, suppressTargets )
    @calendarPath = lewt_settings["ical_filepath"]
    super( dateStart, dateEnd, targets )
  end
  
  # Open iCalender file, parses it, then check events with the regular CalExtractor methods.
  # Sets the data property of this object if match data is found.
  def extractCalendarData
    calendars = Icalendar.parse( File.open( @calendarPath ) )
    calendars.each do |calendar|
      calendar.events.each do |e|
        target = self.isTargetCustomer?( e.summary )
        if  self.isTargetDate?(e.dtstart) == true &&  target != false
          timeDiff = (e.dtstart - e.dtend).to_i / 60 / 60
          row = LEWTLedger.new(e.dtstart, e.dtend, @category, target["name"], e.description, timeDiff, target["rate"])
          @data.add_row( row )
        end
      end
    end
  end

end
