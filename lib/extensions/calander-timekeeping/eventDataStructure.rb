# 
# Generic data structure for storing events info abstracted away into an
# immutable class.
#

class EventDataStructure
  def initialize ( eSummary, eStart, eEnd, eDescription )
    @summary = eSummary
    @start = eStart
    @end = eEnd
    @description = eDescription == "" ? "none" : eDescription
    diff = eEnd - eStart
    @duration = diff.to_i / 60 / 60
    self.freeze
  end

  def self.summary
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



