require_relative "metamath.rb"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.


module LEWT

  # The Metastat extension [experimental] handles processing meta-data added to ledger entries. It can compute statistics based of
  # these parsed values
  #
  # ===Usage:
  # Here is an example 'description' field entered into a LEWTLedger which can be parsed with Metastat
  #
  #  'description' => 'Adding some features to the system #happiness=10 #average-pay'
  #
  # Metastat will extract the # tags from the above string and log an indicatior called happinesswhich is equal to 10
  # and a Boolean switch average-pay will be set to true
  #
  # These values will be aggregate over the whole 'extract' dataset then processed in a few ways.
  #
  # 1. Create a graph out of the data
  # 2. Create a summary table out of the data 

  class Metastat < LEWT::Extension

    attr_reader :client_table, :client_graph

    # Sets up this extension and registers its options
    def initialize
      options = {
        :tags => {
          :definition => "A comma seperated list of metatags to lookup.",
          :type => String
        },
        :y_series => {
          :definition => "An optional y series to use for a correlation analysis.",
          :type => String
        }
      }
      @boolean_table = Hash.new
      @raw_data = Hash.new
      @dataset = Hash.new
      super({:cmd => 'metastat', :options => options})
    end
    
    # Handles the process event for this extension
    # options [Hash]:: The options hash passed to this function by the Lewt program.
    # extract_data [LEWTBook]:: The data in LEWTBook format
    def process (options, extract_data)
      @options = options
      extract_data.each do |row|
        filter_row_values(row, options)
      end
      @dataset["frequency_table"] = @boolean_table
      if options[:y_series]
        @dataset["correlations"] = compute_correlations @raw_data
      end
      return @dataset
    end

    protected
    
    # extracts row data from a LEWTLedger object. Also handles initiating tag lookup.
    # row [LEWTLedger]:: a LEWTLedger object container the row data.
    # options [Hash]:: a Hash containing the options passed to LEWT.
    def filter_row_values (row, options)
      return if row.metatags == nil
      # match tags requested via options
      options[:metatags].split(Lewt::OPTION_DELIMITER_REGEX).each do |meta|
        row.metatags.each { |k, v|
          next unless meta.gsub(Lewt::OPTION_SYMBOL_REGEX,"_").to_sym == k
          # found match operate on it
          client = get_matched_customers(row[:entity])[0]
          # case our value
          case v
          when !!v == v
            add_to_tally( client, row, k, v )
          when Rational
            transform_dataset( client, row, k, v)
          end
        }
      end
    end
    
    # adds +1 count to the client table for the provided key
    # c [Hash]:: The client hash
    # r [LEWTLedger]:: A LEWTLedger row
    # k:: the metatag hash key
    # v:: the meta tag value, this should be a boolean
    def add_to_tally( c, r, k, v )
      if !@boolean_table.has_key?(c["name"])
        @boolean_table[ c["name"] ] = { k.to_s => 0 }
      end

      if !@boolean_table[c["name"]].has_key?(k.to_s)
        @boolean_table[c["name"]][k.to_s] = 0;
      end
      
      @boolean_table[c["name"]][k.to_s] += 1
    end

    # Transforms the dataset into something usable for statistical computation
    # c [Hash]:: The client hash
    # r [LEWTLedger]:: A LEWTLedger row
    # k:: the metatag hash key
    # v:: the meta tag value, this should be a boolean
    def transform_dataset( c, r, k, v )
      if !@raw_data.has_key?(c["name"])
        @raw_data[ c["name"] ] = Array.new
      end
      # prep the data
      @raw_data[c["name"]].push(prepare_row_data(r,k,v))
    end
    
    # prepares normal row for statistical analysis computing some basic numbers we are going to need
    # r [LEWTLedger]:: A LEWTLedger row
    # v:: the meta tag value, this should be a boolean
    def prepare_row_data ( r, k, v )
      data = {
        k.to_sym => v.to_f,
        :duration => r[:quantity].to_f,
        :value => r[:total].to_f
      }
      return data
    end
    
    # performs some statistics using R. 
    # d:: the dataset to work with
    def compute_correlations(d)
      result = nil
      d.each { |context, data_array|
        # hash of arrays
        data_hash = Hash.new
        data_array.each do |r|
          r.each { |k,v|
            data_hash[k] = Array.new if !data_hash.has_key? k
            data_hash[k].push v
          }
        end
        result = correlate_y data_hash, @options[:y_series]
      }
      return result
    end
    
    def correlate_y(r_dataset, y_key)
      results = Hash.new
      r_dataset.each { |k, v_set|
        next if k == y_key.to_sym
        results[y_key.to_sym] = Hash.new if results[y_key.to_sym] == nil
        results[y_key.to_sym][k] = Hash.new if results[y_key.to_sym][k] == nil
        r = PearsonR.new( v_set, r_dataset[y_key.to_sym] )
        results[y_key.to_sym][k][:pearson_r] = r.correlate
        results[y_key.to_sym][k][:descriptive_stats] = r.descriptive_stats(v_set)
      }
      return results
    end

  end
end
