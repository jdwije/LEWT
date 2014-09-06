#!/usr/bin/env ruby

# This script can be invoked to run the tests separately from the rake build.
require 'rubygems'
require 'test/unit'

# Run all of LEWT's test cases.
load 'tc_Lewt.rb'
load 'tc_Billing.rb'
load 'tc_LewtExtension.rb'
load 'tc_LewtLedger.rb'
load 'tc_LewtOpts.rb'
load 'tc_CalExt.rb'

