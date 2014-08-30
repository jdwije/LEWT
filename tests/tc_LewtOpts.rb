require "test/unit"

require_relative "../lib/lewtopts.rb"
require_relative "../lib/extensions/billing/billing.rb"

class TestLewtOpts < Test::Unit::TestCase

  def  test_initialize
    extensions = [
                  Billing.new
                 ]

    simulated_options = {
      :start => DateTime.now - 20,
      :target => "ACME"
    }

    options = LewtOpts.new( extensions, simulated_options )
    assert_instance_of(LewtOpts, options, "LewtOpts not inheriting hash properties properly in libmode.")

#    puts options
    
    assert_instance_of(String, options["target"], "LewtOpts not setting supplied values properly in libmode.")
    assert_equal("ACME", options["target"], "Expected 'ACME' (String) but got #{options["target"]} in libmode.")
  end


end
