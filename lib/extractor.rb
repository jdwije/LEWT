#
# EXTRACTOR Class
# 
# Extracts targeted data from iCal files
require 'icalender'

class Extractor
  @@clientBillStore = Hash.new
  @@filepath
  

  def initialize( calenderPath, dateStart, dateFrom ) 
    @@filepath = calenderPath
    
  end


 # the routine
  def run
    cals = Icalendar.parse( File.open( @@filepath ) )
    cals.each do |cal|
      cal.events.each do |event|
        eStart =  event.dtstart
        eEnd = event.dtend
        eDescription = event.description
        eCustomer = self.isBillableEvent( event )
        if  self.isTargetDate(eStart) == true && eCustomer != false
          evtHoursBillable = ( eEnd.to_time - eStart.to_time ) / 60 / 60
          bill = {
            "client" => eCustomer,
            "hours" => evtHoursBillable,
            "cost" => evtHoursBillable * eCustomer["rate"],
            "eStart" => eStart,
            "eEnd" => eEnd,
            "eDescription" => eDescription
          }
          @@clientBillStore[ eCustomer["name"] ].push( bill )
        end
      end
    end
    self.outputBills()
  end



end
