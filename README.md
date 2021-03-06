# LEWT v0.5.17

LEWT is a command line program & library written in Ruby that can help you invoice customers, manage expenses, generate reports and much more. It is designed to encourage lazy accounting, to get more out of it, and to be extended with minimal friction. 

**Features**

- Can operate in a terminal or as a drop in library for your Ruby programs.
- Simple & concise architecture. Less than 1300 lines of ruby code including the bundled core extensions and tests.
- A nifty extension system that plays well with Ruby Gems.

## Installation

LEWT requires you have [Ruby](https://www.ruby-lang.org/en/) & [Ruby Gems](https://rubygems.org) installed on your machine. Once you have that sorted:

```
 gem install lewt
```

then test with:

```
# output lewt's version number
lewt --version
```

LEWT ships with some dummy data and config so you can jump straight into the quick start guide.

## Quick Start

The LEWT program is based around a procedure I call *extract, process, render* [EPR]. Data is extracted from some source(s) and transformed into a general ledger data structure, this is then passed to the specified processor(s) which may use it to perform calculations, the processed data is then finally passed onto a renderer for outputting in a useful format. All EPR operations are handled by LEWT Extensions, thus a basic LEWT command only involves you specify which extensions to use for the EPR procedure:

```
# -e = extractor, -p = processor, -o = renderer. Outputs an invoice for target customer Wayne Corp [alias: WCorp] since 1 sep 2014
lewt -x calendar -p invoice -o liquid -t WCorp -s 01-09-2014

...

# sample text output
*******
Dear Bruce Wayne,

You have recived a new invoice from Jason Wijegooneratne

*******

Date Created: 17/09/14
ID: 12-4d7d2c79

INVOICED TO:
Wayne Corp,
2 Wayne Street
90210, Gotham,
Cartoon Land,
abn: 45 443 23 123.


INVOICED FROM:
Your Trading Name,
13 Your Street,
0, O-state,
O-stralia,
abn 45 443 23 123.

ITEMS:
--
 03/09/14  7:00pm >>> 04/09/14  5:45am
 $150 * 10.75 hrs = $1612.5
 Hacking on the bat mobile in secrecy. 
--
 10/09/14  7:00pm >>> 11/09/14  3:00am
 $150 * 8.0 hrs = $1200.0
 Hacking on the bat mobile in secrecy. 


---------------------------
SUB-TOTAL: 2812.5
TAX [gst]: 281.25
---------------------------
TOTAL: 3093.75

*******

```

You can also extract from multiple sources at once:

```
# extract time sheet data, expenses, and milestone data for all customers since begining of year and mash it up into a report.
lewt -x expenses,calendar,milestones -s 01-01-2014 -p report -o liquid

...

# sample text output
*******

Date Created: 17/09/14
Included:
 ACME
 Wayne Corp
         
Revenue: 63737.5
Expenses: -740.0
Tax-Levees:
 income tax[0.0]: 0.0
 income tax[0.19]: 3609.81
 income tax[0.325]: 12020.86
 GST[0.1]: 6373.75

Bottom Line: 40993.08
-----------------------------------
Hours Worked: 311.0
*******

```

LEWT's default liquid template rendering extension supports multiple output formats, it can even use WebKit to render a PDF from one of your templates complete with CSS stylesheets support!

```
# output an invoice for specified customer as text, save a pdf simultaneously.
lewt -x expenses,calendar -p invoice -o liquid -t WCorp -s 01-09-2014 --method pdf,text --save-path wcorp-invoice.pdf

# create separate pdf invoices for all customers using some naming templates
lewt -x expenses,calendar -p invoice -o liquid --method pdf -s 01-09-2014 --save-path "#date #alias.pdf"

...

# sample output. files will be written to FS.
20XX-MM-DD ACME.pdf
20XX-MM-DD WCorp.pdf
```

LEWT does not use a database, persisting data is done on a file system:

```
# Persist some processed data in YAML format using the store extension
lewt -t ACME -p invoice -o store >> invoice.yml

# reuse it and output it in plain text
cat invoice.yml | lewt pipe render -p invoice -m text
```

LEWT can even help you generate basic statistics on the fly and supports embedded [metatags](https://github.com/jdwije/LEWT/wiki/Metatags) in your extraction sources:

```
# output a frequency table of hash tags #good-day, #bad-day by customer. use
# store for output as liquid template is dodgy.
lewt -x calendar -p metastat --tags good-day,bad-day -s 01-01-2014 -o store

...

# sample YAML output
---
- frequency_table:
    ACME:
      bad_day: 10
      good_day: 5
    Wayne Corp:
      good_day: 5
      bad_day: 4
```

For a list of options available run:

```
lewt --help
```

You can perform all of the above using LEWT as a library in your projects as well.

```
require "LEWT"


options = {
	:extract => 'calendar',
	:process => 'invoice',
	:render => 'liquid',
	:target => 'ACME',
	:dump_output => false
}

# returns a hash containing the invoice data for further use
lewt_invoice = LEWT::Lewt.new( options ).run 

```

## LEWT Extensions

LEWT by itself is basically just an extension system, all the EPR operations are performed by extensions making LEWT very customisable. Being a beta version of this software, I have shipped LEWT with some basic extension which I find useful in my day to day contracting operations but I'm hoping others will replace them with better versions in time :) these *core extensions* as I will call them for now are:

1. Calendar Timekeeping: Extract Time sheet data from iCal, and OSX Calendar sources and transform it for further processing.
2. Simple Invoices: Process extract data as an invoice.
3. Simple Reports: Process extract data as a report.
4. Liquid Renderer: Liquid template rendering with support for text, html, and PDF tempting.
5. Simple Expenses: Manage expenses with in simple CSV file and extract it into LEWT.
6. Simple Milestones: Manage milestone payments in a CSV file and extract it into LEWT.
7. Store: Persist lewt data as YAML formatted files. Re-use this data later.
8. Metastat: Generate simple statistics from your data sources using embedded metatags.

Conceptually, there are 3 different kinds of extensions: **Extractors, Processors, and Renderers**, however for now they all inherit from the same **LEWT::Extension** base class. This class provides some convenience methods for the extensions as well as a means for them to register themselves within LEWT.

It's pretty easy to get started creating your own extension for LEWT, see the [Authoring LEWT Extensions](https://github.com/jdwije/LEWT/wiki/3-Creating-Extensions-for-LEWT) for more information.


## Configuration

LEWT (and it's extensions) want config. They want it in the form of flat YAML files which can be stored in your ```/config``` directory, see [Installation & Setup](https://github.com/jdwije/LEWT/wiki/2-Installation-&-Setup) for more on this. LEWT's default config directory is ```path/to/lewt/lib/config/``` but you can change this if you like.

## Want to learn more?

Checkout the [WIKI](https://github.com/jdwije/LEWT/wiki) section for a bunch of tutorials on setting LEWT up and getting started writing extensions. The rDocs are available from [here](http://rubydoc.info/gems/lewt/frames) and a google group is setup [here](https://groups.google.com/forum/#!forum/lewt) if you want to keep in touch.

Finally go browse through the source code, there is only ~1300 lines of ruby including comments with which I have tried to be liberal.


## Disclaimer

LEWT is very much beta-ware. I only just started using it myself in my contracting operations, however it's making thing's easier for me so I thought I'd release it as is - when you find those bugs I would love to hear about them!

## License

LEWT is distributed under the terms and conditions of the MIT license, see [LICENSE.md](https://github.com/jdwije/LEWT/blob/master/LICENSE.md) for more information.
















