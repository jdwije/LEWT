require "csv"


class SimpleExpenses < LewtExtension
  
  def initialize
    super({:cmd => "expenses"})
  end

  def extract( options )
    @targets = loadClientMatchData( options["target"] )
    @dStart =  options["start"]
    @dEnd = options["end"]
    @category = 'Expenses'
    exFile = lewt_settings["expenses_filepath"]
    return getExpenses ( exFile )
  end


  # Read file @ filepath and parses it with some rules kinda similar to EMACS ORG-Mode
  # Returns ledger format file
  def getExpenses ( filepath )
    # ROWS:
    # [0]Date [1]Description [2]Context [3]Cost
    count = 0
    data = LEWTBook.new

    CSV.foreach(filepath) do |row|
      if count > 0
        date = DateTime.parse(row[0])
        desc = row[1]
        context = row[2]
        cost = row[3].to_f * -1

        if self.isTargetDate( date ) == true && self.isTargetContext?(context) == true
          # create ledger entry and append to books
          row_data = LEWTLedger.new( date, date, @category, context, desc, 1, cost )
          data.add_row(row_data)       
        end
      end
        # increment our row index counter
      count += 1
    end

    # return our data as per specification!
    return data
  end

  # checks whether event date is within target range
  def isTargetDate ( date ) 
    d = date.to_date
    check = false
    if d >= @dStart.to_date && d <= @dEnd.to_date
      check = true
    end
    return check
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

end
