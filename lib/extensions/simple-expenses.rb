require "csv"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.


module LEWT

  # The Simple Expenses LEWT Extensions allows you to manage you expenses in a CSV file. The CSV
  # file itself must conform to the following specification:
  #
  # ===Row Indexes:
  # [0] Date 
  # [1] Description 
  # [2] Context 
  # [3] Cost
  #
  # The key <tt>expenses_filepath</tt> can be added to your settings file to change the location where this extension looks for the CSV. 

  class SimpleExpenses < LEWT::Extension
    
    # Registers this extension
    def initialize
      super({:cmd => "expenses"})
    end

    # Extracts data from the expenses CSV file.
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    def extract( options )
      @targets = get_matched_customers( options[:target] )
      @dStart =  options[:start]
      @dEnd = options[:end]
      @category = 'Expenses'
      exFile = lewt_settings["expenses_filepath"]
      return get_expenses ( exFile )
    end


    # Read file at filepath and parses it expecting the format presented in this classes header.
    # filepath [String]:: The CSV filepath as a string.
    def get_expenses ( filepath )
      # ROWS:
      # [0]Date [1]Description [2]Context [3]Cost
      count = 0
      data = LEWT::LEWTBook.new
      CSV.foreach(filepath) do |row|
        if count > 0
          date = Time.parse(row[0])
          desc = row[1]
          context = row[2]
          cost = row[3].to_f * -1
          if self.is_target_date?( date ) == true && self.is_target_context?(context) == true
            # create ledger entry and append to books
            row_data = LEWT::LEWTLedger.new({
                                         :date_start => date, 
                                         :date_end => date, 
                                         :category => @category, 
                                         :entity => context,
                                         :description => desc,
                                         :quantity => 1, 
                                         :unit_cost => cost,
                                       })

            data.push(row_data)       
          end
        end
        # increment our row index counter
        count += 1
      end

      # return our data as per specification!
      return data
    end

    # Checks whether event date is within target range
    # date [DateTime]:: The date to check
    # returns: Boolean
    def is_target_date? ( date ) 
      d = date.to_date
      check = false
      if d >= @dStart.to_date && d <= @dEnd.to_date
        check = true
      end
      return check
    end
    
    # Checks if the context field in the CSV matches any of our target clients names or alias'
    # context [String]:: The context field as a string.
    def is_target_context?(context)
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
end
