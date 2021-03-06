require "test/unit"
require_relative "../lib/lewt_ledger.rb"
 
class TestLewtExtension < Test::Unit::TestCase

  def  test_lewt_ledger
    row = create_row
    assert_instance_of(Time, row[:date_start], "#{row.class.name} not storing start Time properly.")
    assert_instance_of(Time, row[:date_end], "#{row.class.name} not storing end Time properly.")
    assert_instance_of(String, row[:category], "#{row.class.name} not storing category properly.")
    assert_instance_of(String, row[:entity], "#{row.class.name} not storing entity  properly.")
    assert_instance_of(String, row[:description], "#{row.class.name} not storing descriptions  properly.")
    assert_equal(1, row[:quantity], "#{row.class.name} not storing quanity properly.")
    assert_equal(40.00, row[:unit_cost], "#{row.class.name} not storing unit_cost properly.")
    assert_equal(40.00, row[:total], "#{row.class.name} not storing totals properly.")
  end

  def test_lewt_books
    books = LEWT::LEWTBook.new
    assert_raise( TypeError ) { books.push(1) }
    row = create_row
    books.push( row )
    assert_instance_of( LEWT::LEWTLedger, books[0], "#{books.class.name} push method not working properly." )
  end


  def create_row
    return LEWT::LEWTLedger.new({
                                  :date_start => Time.now - 8, 
                                  :date_end => Time.now, 
                                  :category => "Expenses", 
                                  :entity => "ACME", 
                                  :description => "Paid for softwware license",
                                  :quantity => 1, 
                                  :unit_cost => 40.00})
  end

end
