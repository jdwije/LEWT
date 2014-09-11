# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

module LEWT

  # The Reports LEWT Extension processes ledger data into a brief report.

  class Reports < LEWT::Extension
    
    # Registers this extension.
    def initialize
      super({:cmd => "report"})
    end

    # Called on Lewt process cycle and uses the ledger data to compose a report.
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    # data [LEWTBook]:: The data in LEWTBook format
    def process ( options, data )
      targets = loadClientMatchData( options[:target] )
      return Array.new.push(make_report(targets, data))
    end

    # This method handles the bulk of the calculation required in compiling the report.
    # targets [Hash]:: The target client(s) to operate on
    # data [LEWTBook]:: The data in LEWTBook format
    def make_report ( targets, data )
      report = {
        "date_created" => DateTime.now.strftime("%d/%m/%y"),
        "included_customers" => targets,
        "revenue" => 0,
        "expenses" => 0,
        "income" => 0,
        "taxes" => Array.new,
        "hours" => 0
      }
      data.each do |row|      
        targets.each do |t|
          # match targets for report
          if row[:entity] == t["name"]
            if row[:category].downcase.match /income/
              report["revenue"] += row[:total]
              # check if category Hourly Income. If so add quantity to our 'hours' counter.
              if row[:category].downcase.match /hourly/
                report["hours"] += row[:quantity]
              end
            elsif row[:category].downcase.match /expense/
              report["expenses"] += row[:total]
            end
          end
        end
      end
      
      # remember expenses is a negative amount to begin with so don't subtract it!
      report["income"] = report["revenue"] + report["expenses"]
      tax_levees = enterprise["tax_levees"]
      tax_total = 0

      if tax_levees != nil
        tax_levees.each do |tax|
          if tax["applies_to"] == "income"
            # do income tax
            if report["income"] > tax["lower_threshold"]
              taxable = [ report["income"], tax["upper_threshold"]].min - tax["lower_threshold"]
              damage = taxable * tax["rate"] + ( tax["flatrate"] || 0 )
              tax_total += damage
              report["taxes"].push({ "amount" => damage, "name" => tax["name"], "rate" => tax["rate"] })
            end
          elsif tax["applies_to"] == "revenue"
            # do GST's
            damage = report["revenue"] * tax["rate"] + ( tax["flatrate"] || 0 )
            tax_total += damage
            report["taxes"].push({ "amount" => damage, "name" => tax["name"], "rate" => tax["rate"] })
          end
        end
      end
      report["bottom_line"] = (report["income"] - tax_total).round(2)
      return report
    end

    def calculate_income_tax (income, tax)
      
    end

  end
end
