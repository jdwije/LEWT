LEWT
====
*Lazy Enterprise for hackers Without Time*

LEWT is a command line program written in Ruby that helps you invoice, manage expenses, and report useful business infomation with minimal friction. It is designed to encourage lazy accounting and to get more out of it.

Here are some example CL's.

```
# output an invoice for specified client to the terminal
lewt invoice -t "CLIENT NAME|ALIAS" -s 01-01-2014 -e 30-01-2014

# as above, but using defaults (current weekly period) and piping into alpine email

lewt invoice -t "CLIENT NAME|ALIAS" | alpine

```

LEWT uses the Liquid Engine for templating so customising *looks* comes easy.

It has handlers to extract events data from Google Calender & iCal files. These use REGEXP to extract specific work events from your calender to generate your invoices with. It parses this data and hands it onto the Liquid Engine for formatting.

LEWT aims to make your business data scriptable.

I am in the process of restructuring this project to be more extensible, whilst the code is currently working the next version will be very different.



## Basic Setup

There are several config files you will need to tailor to your enterprise before we get started. See the ```config/``` directory for more...






