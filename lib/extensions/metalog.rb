# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# The MetaLog extension handles processing meta-data added to ledger entries. It can compute statistics based of
# these parsed values
#
# ===Usage:
# Here is an example 'description' field entered into a LEWTLedger which can be parsed with MetaLog
#
#  'description' => 'Adding some features to the system #happiness=10 #average-pay'
#
# MetaLog will extract the # tags from the above string and log an indicatior called happinesswhich is equal to 10
# and a Boolean switch average-pay will be set to true
#
# These values will be aggregate over the whole 'extract' dataset then processed in a few ways.
#
# 1. Create a graph out of the data
# 2. Create a summary table out of the data 

class Metalog < LewtExtension

  
  # Sets up this extension and registers its options
  def initialize
    options = {
      :metatags => {
        :definition => "A comma seperated list of metatags to lookup",
        :type => String
      }
    }
    super({:cmd => 'metalog', :options => options})
  end
  
  # Handles the process event for this extension.
  # options [Hash]:: The options hash passed to this function by the Lewt program.
  # data [LEWTBook]:: The data in LEWTBook format
  def process (options, data)
    metaReport = {
      :metaReport => Array.new
    }    
    data.each do |row|
      row_stat = extract_row(row, options)
      metaReport[:metaReport].push row_stat
    end
    return Array.new().push(metaReport)
  end

  protected
  
  def extract_row (row, options)
    date = row[:date_start]
    cat = row[:category]
    client = self.loadClientMatchData(row[:entity])
    quantity = row[:quantity]
    total = row[:total]
    tags = row.metatags
    if tags != nil 
      searchtags = options[:metatags].gsub(/[,+:]/,"|")
      tags.each { | n, v |
        if n.to_s.match(/#{searchtags}/) != nil
          
        end
      }
    end
  end

end
