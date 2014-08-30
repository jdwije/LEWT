require "test/unit"
require_relative "../lib/lewt_ledger.rb"
 
class TestLewtExtension < Test::Unit::TestCase

  def  test_lewt_ledger
    row = create_row
    assert_instance_of(DateTime, row["date_start"], "#{row.class.name} not storing start DateTime properly.")
    assert_instance_of(DateTime, row["date_end"], "#{row.class.name} not storing end DateTime properly.")
    assert_instance_of(String, row["category"], "#{row.class.name} not storing category properly.")
    assert_instance_of(String, row["entity"], "#{row.class.name} not storing entity  properly.")
    assert_instance_of(String, row["description"], "#{row.class.name} not storing descriptions  properly.")
    assert_equal(1, row["quantity"], "#{row.class.name} not storing quanity properly.")
    assert_equal(40.00, row["unit_cost"], "#{row.class.name} not storing unit_cost properly.")
    assert_equal(40.00, row["total"], "#{row.class.name} not storing totals properly.")
  end

  def test_lewt_books
    books = LEWTBooks.new
    assert_raise( TypeError ) { books.add_row(1) }
    row = create_row
    books.add_row( row )
    assert_instance_of( LEWTLedger, books[0], "#{books.class.name} push method not working properly." )
  end


  def create_row
    return LEWTLedger.new( DateTime.now - 8, DateTime.now, "Expenses", "ACME", "Paid for softwware license", 1, 40.00, 40.00)    
  end

end
