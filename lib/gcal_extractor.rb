#!/usr/bin/ruby

# This is a handler for extracting calDAV data from a server and converting it into the locally understood data structure.

load "./lib/eds.rb"
load "./lib/extractor.rb"

require 'rubygems'
require 'google_calendar'


class GCalExtractor < Extractor

  def initialize ( dStart, dEnd, matchingQueries )
    calendarPath = Google::Calendar.new(:username => 'admin@jwije.com',
                           :password => 'cxfroeopthxtuqwv',
                           :app_name => 'jwije.com-googlecalendar-integration')
    super( calendarPath, dStart, dEnd, matchingQueries )
  end

 # references the event title against clients for matching
  # billable events
  def isTargetEvent ( evt )
    eTitle = evt.title
    match = false
    @matchingQueries.each do |query|
      if query == eTitle
        match = query
      end
    end
    return match
  end
   
  # returns the extracted calendar data
  def extractCalendarData
    
    @calendarPath.events.each do |e|
      eStart = Time.parse( e.start_time )
      eEnd = Time.parse( e.end_time )
      if  self.isTargetDate( eStart ) == true && self.isTargetEvent( e ) != false
        @data.push( 
                   EventDataStructure.new( 
                                          e.title, 
                                          eStart,
                                          eEnd,
                                          e.content 
                                          ) 
                   )
      end
    end
  end

end



# run = GCalExtractor.new( DateTime.parse("01-05-2014"), DateTime.parse("01-06-2014"), ["TTS", "TipTop Select"])







