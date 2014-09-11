#!/usr/bin/env ruby

# Test Cases for the Billing core extension.
# ./lib/extension.rb
#
# Written by: jdw <4 July 2014>
#
# ********************************************

require "test/unit"

require_relative "../lib/extension.rb"
require_relative "../lib/extensions/calendar-timekeeping/calendar-timekeeping.rb"
 
class TestCalendarTimekeeping < Test::Unit::TestCase

  def  test_initialize
    caltime = LEWT::CalendarTimekeeping.new
    assert_instance_of( LEWT::CalendarTimekeeping, caltime, "Extension CalandarTimekeeping not initialising properly." )
    calext = CalendarExtractors::CalExtractor.new( (DateTime.now - 8)::to_s, DateTime.now::to_s,"ACME")
    assert_instance_of( CalendarExtractors::CalExtractor, calext, "Extension CalandarTimekeeping sub-module CalExtractor not initialising properly." )
  end

  def test_filtering_methods
    calext = CalendarExtractors::CalExtractor.new( (DateTime.now - 8)::to_s, DateTime.now::to_s, LEWT::Extension.new::loadClientMatchData("ACME") )
    assert_instance_of(Hash, calext.isTargetCustomer?("ACME"), "#{calext.class.name} not matching customer names properly.")
    assert_instance_of(Hash, calext.isTargetCustomer?("ACME doing some stuff"), "#{calext.class.name} not matching customer names properly.")
    assert_instance_of(Hash, calext.isTargetCustomer?("making thing! ACME"), "#{calext.class.name} not matching customer names properly.")
    assert_instance_of(Hash, calext.isTargetCustomer?("AC"), "#{calext.class.name} not matching customer alias' properly.")
    assert_instance_of(Hash, calext.isTargetCustomer?("AC: building stuff"), "#{calext.class.name} not matching customer alias' properly.")
    assert_instance_of(Hash, calext.isTargetCustomer?("creating features AC"), "#{calext.class.name} not matching customer alias' properly.")
    assert_equal(true, calext.isTargetDate?( DateTime.now - 2 ), "#{calext.class.name} not matching targeted dates properly.")
    assert_equal(false, calext.isTargetDate?( DateTime.now - 50 ), "#{calext.class.name} not ignoring un-targeted dates properly.")
  end

  

end






