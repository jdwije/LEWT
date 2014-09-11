# LEWT

LEWT is a command line program & library written in Ruby that can help you invoice customers, manage expenses, generate reports and much more. It is designed to encourage lazy accounting and to get more out of it. It is also designed to be extended with minimal friction making integrating it with your existing setups (or creating entirely new ones) as painless as it can get.

**Features**

- Can operate in a terminal or as a drop in library in your Ruby programs.
- Simple & concise architecture. Less than 1500 lines of ruby code including the bundled core extensions.
- A nifty extension system.

## Installation

LEWT requires you have Ruby & Ruby Gems installed on your machine. Once you have that sorted:

```
 gem install lewt
```

## Quick Start

The LEWT program is based around a procedure I call *extract, process, render* [EPR]. Data is extracted from some source(s) and transformed into a general ledger data structure, this is then passed to the specified processor(s) which may use it to perform calculations, the processed data is then finally passed onto a renderer for outputting in a useful format.

Put it all together and you can mash up some CLs.

```
 # output an invoice for client ACME to the terminal in PLAIN text. Extract time sheet data and work expenses from the last week for this (default)
 lewt -x expenses,calendar -p invoice -o liquid -t ACME


 # output an invoice for specified client as a html, save a pdf simultaneously.
 lewt -x expenses,calendar -p invoice -o liquid -t ACME --method pdf, html --save-file acme-invoice.pdf

 # mash up a bunch of extraction sources and process it as a report.
 lewt -x expenses,calendar,milestones -p report -o liquid --method text,pdf --save-file business_report.pdf

 # Persist an invoice using the store extensions
 lewt -p invoice -o store >> invoice.yml

 # reuse it and output in plain text
 cat invoice.yml | lewt pipe process -p invoice -m text

 # Generate and outputs PearsonR & Descriptive stats for metatag 'happiness'
lewt -x calendar -p metastat --metatag happiness -t ACME

```

The neat thing about LEWT is that extractors must all return there data in a pre-specified format, thus a universal compatibility can be maintained between extractors and any processor.

## LEWT Extensions

LEWT by itself is basically just an extension system, all the EPR operations are performed by extensions making LEWT very customisable. Being a beta version of this software, I have shipped LEWT with some basic extension which I find useful in my day to day contracting operations. These *core extensions* as I will call them for now are:

1. Calendar Timekeeping: Extract Time sheet data from iCal, OSX Calendar, and Google Calender sources and transform it for further processing.
2. Simple Invoices: Process extract data as an invoice.
3. Simple Reports: Process extract data as a report.
4. Liquid Renderer: Liquid template rendering with support for text, html, and PDF tempting.
5. Simple Expenses: Manage expenses with in simple CSV file and extract it to LEWT.
6. Simple Milestones: Manage milestone payments in a CSV file and extract it to LEWT.
7. Store: Persist lewt data as YAML formatted files. Re-use this data later.
8. Metastat: Generate simple statistics from your data sources using embedded metatags.

Conceptually, there are 3 different kinds of extensions: **Extractors, Processors, and Renderers<**. However for now they all inherit from the same **LEWT::Extension** base class. This class provides some convenience methods for the extensions as well as a means for them to register themselves within LEWT - specifying options such as command line flags and call handles.

It's pretty easy to create you own extension all you need to do is create a folder in your extensions directory with a **.rb** file in it with the same name as the parent directory. This directory will house all your extension code, the naming convention is used for initialization. Alternatively you can create a Ruby Gem and have it loaded at run time by specified it in your settings.yml config file. See the [Authoring LEWT Extensions](https://github.com/jdwije/LEWT/wiki/3-Creating-Extensions-for-LEWT) for more information.


## Config

LEWT (and it's extensions) want config. They want it in the form of flat YAML files which can be stored in your ```/config``` directory, see [Installation & Setup](https://github.com/jdwije/LEWT/wiki/2-Installation-&-Setup) for more on this. LEWT's default config directory is ```path/to/lewt/lib/confg/``` but you can change this if you like.

## Why Use LEWT?

One word - Automation. Accounting sucks, I hate it, luckily it's one of the easiest tasks to automate. If like me you operate as a contractor, LEWT can help you gain visibility over your operations again - fire your accountant, they make you do the hard work anyway! LEWT does it for you, and it's free (as in free beer) distributed under an MIT license.















