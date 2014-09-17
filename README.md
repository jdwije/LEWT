# LEWT v0.5.12

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
# -e = extractor, -p = processor, -o = renderer. Outputs an invoice for target customer ACME
lewt -x calendar -p invoice -o liquid -t ACME
```

You can also extract from multiple sources at once:

```
# extract time sheet data, expenses, and milestone data for all customers and mash it up into a report
lewt -x expenses,calendar,milestones -p report -o liquid
```

LEWT's default liquid template rendering extension supports multiple output formats, it can even use WebKit to render a PDF from one of your templates complete with CSS stylesheets support!

```
# output an invoice for specified customer as text, save a pdf simultaneously.
lewt -x expenses,calendar -p invoice -o liquid -t ACME --method pdf, text --save-path acme-invoice.pdf

# create separate pdf invoices for all customers using some naming templates
lewt -x expenses,calendar -p invoice -o liquid --method pdf, html --save-path "#alias #date.pdf"
```

LEWT does not use a database, persisting data is done on a file system:

```
# Persist some processed data in YAML format using the store extension
lewt it ACME -p invoice -o store >> invoice.yml

# reuse it and output it in plain text
cat invoice.yml | lewt pipe process -p invoice -m text
```

LEWT can even help you generate statistics on the fly and supports embedded [metatags](#) in your extraction sources:

```
# output a frequency table of hash tags #good-day, #bad-day by customer
lewt -x calendar -p metastat --tags good-day,bad-day

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

1. Calendar Timekeeping: Extract Time sheet data from iCal, OSX Calendar, and Google Calender sources and transform it for further processing.
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

Checkout the [WIKI](https://github.com/jdwije/LEWT/wiki) section for a bunch of tutorials on setting LEWT up and getting started writing extensions.

Finally go browse through the source code, there is only ~1300 lines of ruby including comments with which I have tried to be liberal.


## Disclaimer

LEWT is very much beta-ware. I only just started using it myself in my contracting operations, however it's making thing's easier for me so I thought I'd release it as is - if (when) you find any bugs I'd love to hear about them!

## License

LEWT is distributed under the terms and conditions of the MIT license, see LICENSE.md for more information.
















