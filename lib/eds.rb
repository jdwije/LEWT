# 
# Generic data structure for storing events info abstracted away into an
# immutable class.
#

class EventDataStructure
  def initialize ( eSummary, eStart, eEnd, eDescription )
    @summary = eSummary
    @start = eStart
    @end = eEnd
    @description = eDescription
    @duration = ( eEnd.to_time - eStart.to_time ) / 60 / 60
    self.freeze
  end

  def summary
    return @summary
  end

  def start 
    return @start
  end

  def end
    return @end
  end

  def description
    return @description
  end

  def duration
    return @duration
  end

end
