# LEWTLedger is a pre-formated hash structure that conforms somewhat to a standard general ledger entry.
#
# ===Keys
#  date_start:: Start date the entry occured on
#  date_end:: End date the entry occured on
#  category:: Some sort of general category for this entry i.e: 'Hourly Income', 'Operating Expenses' etc.
#  entity:: The entiry with whom this transaction occured with
#  description:: A description of the entry
#  quantity:: How many units
#  unit_cost:: The cost per unit
#  sub_total (optional):: A total or defaults to quantity * unit_cost
#  gst (optional):: The GST (VAT) amount to be added for this entry. Defaults to 0.
#  total (optional):: The total, including tax, for this entry. Defaults to sub_total + gst
#
# ===Usage
#  ledger = LEWTLedger.new(params, ...)
#
# Furthermore LEWTLedger provides some methods to work with metatags. Metatags can be embedded inside your extraction sources.
# I like to put mine in my 'description' fields, it works well with Calender Extractor. The meta data is basically a hash tag, you
# can do stuff like this:
#
#  '#happiness=10/10'
#  '#ignore-cost'
# 
# meta tags that do not assign a value [ie: =something] will evaluate to a boolean true flag. If you assign a value it must 
# be a fraction, this will be evaluated as a ruby Rational type. Your extensions can respond to these tags however they like.
# The metatags can be accessed with the <tt>metatags</tt> reader attribute:
#   ledger_data.metatags
#

class LEWTLedger < Hash

  attr_reader :metatags
  
  # This is a general matching regex for metatags.
  MATCH_SINGLE_META_REGEX = /[#](\S*)/
  MATCH_MULTIPLE_META_REGEX = /#\S*/

  def  initialize ( date_start, date_end, category, entity, description, quantity, unit_cost, sub_total = nil, gst = nil, total = nil  )
    self[:date_start] = date_start
    self[:date_end] = date_end
    self[:category] = category
    self[:entity] = entity
    self[:description] = description
    self[:quantity] = quantity
    self[:unit_cost] = unit_cost
    self[:sub_total] = sub_total || quantity * unit_cost
    self[:gst] = gst || 0
    self[:total] = total || ( self[:sub_total] + self[:gst] )
    @metatags = parse_meta_tags(:description)
    strip_readable_meta if @metatags != nil
  end
  
  # parses a field on this object for meta data. Meta data can be embedded inside the ledger fields
  # as a string by prefixing it with the '#' symbol. If you assign a value to the meta field with the '='
  # symbol, its value will be interpreted as a number.
  # ie: 
  #  #good-pay // true
  #  #happiness=6/10 // Rational(6,10)
  # field_key [Symbol]:: the ledger key you wish to parse as a symbol.
  def parse_meta_tags ( field_key )
    value = self[field_key]
    tags = parse_tags value
    return tags
  end
  
  protected
  
  # strips the meta data from a field so that it is no longer readable. leaves the metatags property on the object intact however
  # field:: A Symbol corresponding to the field on this object to strip. Defaults to the description field.
  def strip_readable_meta ( field = :description )
    self[field].scan(LEWTLedger::MATCH_MULTIPLE_META_REGEX).each do |m|
      self[field].slice!(m).strip!
    end
  end

  # this function extracts all tags/values from a given string.
  # string [String]:: a string to search for meta tags in.
  def parse_tags (string)
    tags = nil
    string.scan(LEWTLedger::MATCH_SINGLE_META_REGEX) { |t|
      if tags == nil
        tags = Hash.new
      end
      tag_value = parse_tag_value t[0]
      tag_name = parse_tag_name t[0]
      tags[tag_name.gsub(/\W/,"_").to_sym] = tag_value
    }
    return tags
  end

  # parses the name of a tag and returns it as a symbol to be used as a hash key
  # tag [string] a string containing the a singular meta tag.
  def parse_tag_name( tag )
    match_name = /[^=]*/
    m = tag.match(match_name)
    return m[0]
  end
  
  # parses the value of a meta tag string. if just the string is given (ie: no = xx/xx) then the tag will have
  # a value of true returned for it.
  # tag [String]:: a meta tag string
  def parse_tag_value ( tag )
    match_value = /[=]\d*\/\d*/
    match = tag.match match_value
    # if no value found then this must be a boolean switch (because a tag was parsed from the field!) so set value to true
    value = match != nil ? extract_fraction(match[0]) : true
    return value
  end
  
  # extracts a mathematical expression from a single tag
  # format: Num +-/* Num
  # string:: the string to extract the fraction from
  def extract_fraction ( string )
    match_fraction = /(\d{1,})([\/\+])(\d{1,})+/
    #    m = string.match(match_fraction)[0]
    m = string.match(match_fraction)
    value = nil
    if m != nil
      value = Rational m[0]
    end
    
    return value
  end

end
