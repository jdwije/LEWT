# Author::    Jason Wijegooneratne  (mailto:code@jwije.com)
# Copyright:: Copyright (c) 2014 Jason Wijegooneratne
# License::   MIT. See LICENSE.md distributed with the source code for more information.

# The LEWTBook is used by extractors as a generic data structure to adhere to when
# returning there results.
# It follows a basic *general ledger* format without the double-entry book keeping.
#
# ===Usage:
#
# lewtbook = LEWTBook.new()
# lewtbook.add_row( LEWTLedger.new( params, ... ) )
#

class LEWTBook < Array

  # ===Note:
  # Ideally I would like to override the Array.push method for LEWTBooks in such a way
  # that when LEWTBook.push is called, that when the *if* type check clause is not met
  # an error is raised otherwise the element is added via Array.push. I am still not clear
  # on the in-and-outs of method riding in ruby so I am adding a new method add_row
  # instead to keep things simple for myself.
  #
  
  def self.push ( element )
    add_row( element )
  end

  # adds a row to this element as per array.push. only accespts LEWTLedger objects as entries.
  # element [LEWTLedger]:: An initialised LEWTLedger object containing your data.
  def add_row ( element )
    if element.class.name == 'LEWTLedger'
      push(element)
    else
      raise TypeError, "Class #{self.class.name} only accepts LEWTLedger objects as its contents"
    end
  end
end

# LEWTLedger is a preformated hash structure that conforms somewhat to a general ledger entry.
#
# ===Keys:
# date_start:: Start date the entry occured on
# date_end:: End date the entry occured on
# category:: Some sort of general category for this entry i.e: 'Hourly Income', 'Operating Expenses' etc.
# entity:: The entiry with whom this transaction occured with
# description:: A description of the entry
# quantity:: How many units
# unit_cost:: The cost per unit
# sub_total (optional):: A total or defaults to quantity * unit_cost
# gst (optional):: The GST (VAT) amount to be added for this entry. Defaults to 0.
# total (optional):: The total, including tax, for this entry. Defaults to sub_total + gst
#
# ===Usage:
#
# ledger = LEWTLedger.new(params, ...)
class LEWTLedger < Hash
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
  end
end
