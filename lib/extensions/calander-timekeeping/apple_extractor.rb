require 'icalendar'

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# This class handles extraction from iCal sources.
#
# ===Usage:
# - Add the key <tt>osxcal_path</tt> to your settings file and set its value to the location of your calender directory. This must
#   be the full path.

class AppleExtractor < CalExtractor

  # Initialises the object and calls the parent class' super() method.
  def initialize( dateStart, dateEnd, targets, lewt_settings, suppressTargets ) 
    @calendarPath = lewt_settings["osxcal_path"]
    @suppressTargets = suppressTargets
    super( dateStart, dateEnd, targets )
  end

  
  # Scans the apple calender storage directory and compiles a mashup of ical data it finds
  def aggregateAppleCalenders
    calenders = Array.new
    Dir.glob("#{@calendarPath}**/*.ics").each do |path|
      calenders += Icalendar.parse( File.open(path) )
    end
    return calenders
  end

  # Open iCalender file, parses it, then check events with the regular CalExtractor methods.
  # Sets the data property of this object if match data is found.
  def extractCalendarData
    calendars = aggregateAppleCalenders()
    calendars.each do |calendar|
      calendar.events.each do |e|
        target = self.isTargetCustomer?( e.summary )
        if  self.isTargetDate?(e.dtstart) == true &&  target != false
          timeDiff = (e.dtend - e.dtstart).to_i / 60 / 60
          row = LEWTLedger.new(e.dtstart, e.dtend, @category, target["name"], e.description, timeDiff, target["rate"])
          @data.add_row( row )
        end
      end
    end
  end

end
