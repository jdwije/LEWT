require "rinruby"

# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# The Metastat extension handles processing meta-data added to ledger entries. It can compute statistics based of
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

class Metastat < LewtExtension

  attr_reader :client_table, :client_graph

  # Sets up this extension and registers its options
  def initialize
    options = {
      :metatags => {
        :definition => "A comma seperated list of metatags to lookup",
        :type => String
      },
      :y_series => {
        :definition => "The y series to use for a simple regresion",
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
      inspect_row(row, options)
    end
    @dataset[:boolean_table] = @boolean_table
    @dataset[:statistics] = compute_stats @raw_data
    return Array.new.push @dataset
  end

  protected
  
  # extracts row data from a LEWTLedger object. Also handles initiating tag lookup.
  # row [LEWTLedger]:: a LEWTLedger object container the row data.
  # options [Hash]:: a Hash containing the options passed to LEWT.
  def inspect_row (row, options)
    tags = row.metatags
    if tags != nil 
      # match tags requested via options
      options[:metatags].split(Lewt::OPTION_DELIMITER_REGEX).each do |meta|
        tags.each { |k, v|
          next unless meta.gsub(Lewt::OPTION_SYMBOL_REGEX,"_").to_sym == k
          # found match operate on it
          client = loadClientMatchData(row[:entity])[0]
          # case our value
          case v
          when !!v == v
            push_boolean_table( client, row, k, v )
          when Rational
            push_raw_data( client, row, k, v)
          end
        }
      end
    end
    return row
  end
  
  # adds +1 count to the client table for the provided key
  # c [Hash]:: The client hash
  # r [LEWTLedger]:: A LEWTLedger row
  # k:: the metatag hash key
  # v:: the meta tag value, this should be a boolean
  def push_boolean_table( c, r, k, v )
    if !@boolean_table.has_key?(c["name"])
      @boolean_table[ c["name"] ] = { k.to_s => 0 }
    end
    @boolean_table[ c["name"] ][k.to_s] += 1
  end

  # computes a row of graphable data
  # c [Hash]:: The client hash
  # r [LEWTLedger]:: A LEWTLedger row
  # k:: the metatag hash key
  # v:: the meta tag value, this should be a boolean
  def push_raw_data( c, r, k, v )
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
  def compute_stats(d)
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
      result = compute_regression data_hash, @options[:y_series]
    }
    return result
  end

  def compute_regression(r_dataset, y_key)
    results = Hash.new
    r_dataset.each { |k, v_set|
      next if k == y_key.to_sym
      results[y_key.to_sym] = Hash.new if results[y_key.to_sym] == nil
      results[y_key.to_sym][k] = Hash.new if results[y_key.to_sym][k] == nil

      r = PearsonCorrelation.new( v_set, r_dataset[y_key.to_sym] )
      results[y_key.to_sym][k][:pearson_correlate] = r.correlate
      results[y_key.to_sym][k][:x_mean] = r.mean(v_set)
    }
    return results
  end

end

class StatObject

  def initialize(xs, ys)
    @xs, @ys = xs, ys
    if @xs.length != @ys.length
      raise "Unbalanced data. xs need to be same length as ys"
    end
  end
 
  def y_intercept
    mean(@ys) - (slope * mean(@xs))
  end
 
  def slope
    x_mean = mean(@xs)
    y_mean = mean(@ys)
 
    numerator = (0...@xs.length).reduce(0) do |sum, i|
      sum + ((@xs[i] - x_mean) * (@ys[i] - y_mean))
    end
 
    denominator = @xs.reduce(0) do |sum, x|
      sum + ((x - x_mean) ** 2)
    end
 
    (numerator / denominator)
  end
 
  def mean(values)
    total = values.reduce(0) { |sum, x| x + sum }
    Float(total) / Float(values.length)
  end
end


class PearsonCorrelation < StatObject
  
  def initialize (xs, ys)
    super(xs,ys)
  end
  
  def correlate
    x_mean = mean(@xs)
    y_mean = mean(@ys)
 
    numerator = (0...@xs.length).reduce(0) do |sum, i|
      sum + ((@xs[i] - x_mean) * (@ys[i] - y_mean))
    end
 
    denominator = @xs.reduce(0) do |sum, x|
      sum + ((x - x_mean) ** 2)
    end
 
    (numerator / Math.sqrt(denominator))
  end
 

end
