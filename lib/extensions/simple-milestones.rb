require "csv"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# Extracts milestone payment data from a CSV file.
#
# ===Row Indexes:
# [0] Id 
# [1] Date
# [2] Description
# [3] Context
# [4] Amount
#
# The key <tt>milstones_filepath</tt> can be added to your settings file to change the location where this extension looks for the CSV. 


class SimpleMilestones < LewtExtension
  
  # Sets up this extension and regsters its run-time options.
  def initialize
    @category = "Milestone Income"
    super({:cmd => "milestones"})
  end

  # Extracts data from the milestones CSV file.
  # options [Hash]:: The options hash passed to this function by the Lewt program.
  def extract( options )
    matchData = loadClientMatchData( options["target"] )
    @dStart =  options["start"].to_date
    @dEnd = options["end"].to_date
    @targets = self.loadClientMatchData(options["target"])
    exFile = lewt_settings["milestones_filepath"]
    return getMilestones ( exFile )
  end

  # Read file at filepath and parses it expecting the format presented in this classes header.
  # filepath [String]:: The CSV filepath as a string.
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

  # Checks if the context field in the CSV matches any of our target clients names or alias'
  # context [String]:: The context field as a string.
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

  # Checks whether event date is within target range
  # date [DateTime]:: The date to check
  # returns: Boolean
  def isTargetDate?(date) 
    d = date.to_date
    check = false
    if d >= @dStart && d <= @dEnd
      check = true
    end
    return check
  end
  
end
