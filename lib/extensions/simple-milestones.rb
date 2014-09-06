require "csv"


class SimpleMilestones < LewtExtension
  
  def initialize
    @category = "Milestone Income"
    super({:cmd => "milestones"})
  end

  def extract( options )
    matchData = loadClientMatchData( options["target"] )
    @dStart =  options["start"].to_date
    @dEnd = options["end"].to_date
    @targets = self.loadClientMatchData(options["target"])
    exFile = lewt_settings["milestones_filepath"]
    return getMilestones ( exFile )
  end

  # Read file @ filepath and parses it with some rules kinda similar to EMACS ORG-Mode
  # Returns ledger format file
  def getMilestones ( filepath )
    # ROWS:
    # [0]Id [1]Date [2]Description [3]Context [4]Amount
    count = 0
    data = LEWTBook.new

    CSV.foreach(filepath) do |row|
      if count > 0
        id = row[0]
        date = DateTime.parse(row[1])
        desc = row[2]
        context = row[3]
        amount = row[4].to_f

        if self.isTargetDate?( date ) == true && self.isTargetContext?(context) == true
          # create ledger entry and append to books
          row_data = LEWTLedger.new( date, date, @category, context, desc, 1, amount )
          data.add_row(row_data)
        end
      end
        # increment our row index counter
      count += 1
    end
    return data
  end

  def isTargetContext?(context)
    match = false
    @targets.each do |t|
      reg = [ t['alias'], t['name'] ]
      regex = Regexp.new( reg.join("|"), Regexp::IGNORECASE )
      match = regex.match(context) != nil ? true : false;
      break if match != false
    end
    return match
  end

  # checks whether event date is within target range
  def isTargetDate?(date) 
    d = date.to_date
    check = false
    if d >= @dStart && d <= @dEnd
      check = true
    end
    return check
  end
  
end
