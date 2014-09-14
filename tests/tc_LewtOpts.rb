require "test/unit"

require_relative "../lib/lewtopts.rb"
require_relative "../lib/extensions/simple-invoices.rb"

class TestLewtOpts < Test::Unit::TestCase

  def  test_initialize
    extensions = [
                  LEWT::SimpleInvoices.new
                 ]

    simulated_options = {
      :start => DateTime.now - 20,
      :target => "ACME"
    }

    options = LEWT::LewtOpts.new( extensions, simulated_options )
    assert_instance_of(LEWT::LewtOpts, options, "LewtOpts not inheriting hash properties properly in libmode.")

    assert_instance_of(String, options[:target], "LewtOpts not setting supplied values properly in libmode.")
    assert_equal("ACME", options[:target], "Expected 'ACME' (String) but got #{options[:target]} in libmode.")
  end


end
