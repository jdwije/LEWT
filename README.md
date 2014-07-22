LEWT
====
*Lazy Enterprise for hackers Without Time*

LEWT is a command line program written in Ruby that helps you invoice, manage expenses, and report useful business information with minimal friction. It is designed to encourage lazy accounting and to get more out of it. It is also designed to be further extended from the ground up...

# Installation

Install LEWT as a GEM.

```
gem install lewt
```

# The Basics

The LEWT program is based around a loop construct I call *extract, process, render* [EPR]. Data is extracted from some sources and transformed into a general ledger format, this is then passed to the specified processor(s) which may use it to perform operations, the processors working are then finally passed onto your renderer for outputting into a useful format.

LEWT by itself is basically just an extension system, all the EPR operations are performed by extensions making LEWT highly customisable. Being an fledgling version of this software, I have shipped LEWT with some basic extension which I find useful in my day to day contracting operations. These *core extensions* as I will call them for now are...

1. Calender Time-Keeping: Extract Time sheet data from iCal and Google Calender sources and transform it into the general ledger format.
2. Simple Invoices: Process ledger data as an invoice.
3. Simple Reports: Process ledger data as a report.
4. Liquid Renderer: .liquid template rendering for your all your shizz including PDFs.
5. Simple Expenses: Manage expenses like a poon using CSVs.
6. Simple Milestones: Do milestones like a total poon using CSVs.

Put it all together and you can mash up some CLs.

```
# output an invoice for client ACME to the terminal in PLAIN text. Extract time sheet data and work expenses from the last week for this (default)
lewt -x expenses,calender -p invoice -r liquid -t ACME

# output an invoice for specified client as a html, save a pdf simultaneously.
lewt -x expenses,calender -p invoice -r liquid -t ACME --template invoice --method pdf, html --save-file acmeXX-XX-XXXX.pdf 

# mash up a bunch of extraction sources and process it as a report.
lewt -x expenses,calender,milestones -p report -r liquid --template report --method text,pdf --save-file mash_report.pdf

```
The neat thing about LEWT is that extractors must all return there data in this general ledger format, thus a universal compatibility can be maintained with any processor. Processors must also always return hashes to be used by the renderer, they share a similar compatibility albeit less autonomous.

# Extensions

Your business work flows probably differ from mine. Both of ours are likely to change over time as well - LEWT extension system is designed to support that.

Conceptually, there are 3 different kinds of extensions: **Extractors, Processors, and Renderers**. However for now they all inherit from the same ``` LEWTExtension``` base class. This class provides some convenience methods for the extensions as well as a means for them to register themselves within LEWT - specifying options such as command line flags and call handles.

It's pretty easy to create you own extension all you need to do is create a folder in your extensions directory with a *.rb* file in it with the same name as the parent directory. This directory will house all your extension code, the naming convention is used for initialization. Alternatively you can create a Ruby Gem and have it loaded at run time by specified it in your settings.yml config file.

Here is a minimal implementation of a LEWT extensions, an extractor in this case.

```
# mmm... more to come.

```

# Config

LEWT extensions want config. They want it in the form of flat .yml [YAML](http://yaml.org) files. They reside in your config directory which can be found at ```path-to-lewt/lib/config```. Strictly speaking you could use some other format, however I have chosen YAML as the preferred format for the LEWT project because it is human readable whilst still being serializable. This is important to encourage lazy enterprise, you can always edit the .yml files by hand in a text editor and any programs with or on top of LEWT (ie GUIs or whatever) will totally be able to deal with it. Please prefer YAML over other formats where possible when architecting your extensions.

# Why use LEWT?

Because its esoteric and arcane, and if your anything like me it's still faster than PayPal or other similar systems even with my simplistic core extensions. You can also include LEWT as a drop in library as well as using it on the command line - all extensions are available in both environments making LEWT and all its extensions generally more useful. Everything in LEWT except for the extract, process, render cycle and a few basic command lines is customisable and designed to be that way, LEWT was made so you can automate accounting your way.











