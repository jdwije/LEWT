#!/usr/bin/env ruby

class Reports < LewtExtension

  def initialize
    super({:cmd => "report"})
  end

  def process ( options, data )
    targets = loadClientMatchData( options["target"] )
    return Array.new.push(make_report(targets, data))
  end

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
        if row["entity"] == t["name"]
          if row["total"] > 0
            report["revenue"] += row["total"]
          else
            report["expenses"] += row["total"]
          end

          if row["category"] == "Hourly Income"
            report["hours"] += row["quantity"]
          end

        end
      end
    end
    
    report["income"] = report["revenue"] - report["expenses"]
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
