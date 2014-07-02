LEWT
====
*Lazy Enterprise for hackers Without Time*

LEWT is a command line program written in Ruby that helps you invoice, manage expenses, and report useful business infomation with minimal friction. It is designed to encourage lazy accounting and to get more out of it.

Here are some example CL's.

```
# output an invoice for specified client to the terminal in PLAIN text
lewt invoice "CLIENT_NAME|ALIAS" -s 01-01-2014 -e 30-01-2014 -o

# as above, but using defaults (current weekly period) and piping into alpine email
lewt invoice -t "CLIENT_NAME|ALIAS" -o | alpine

# output an invoice for specified client as a PDF
lewt invoice "CLIENT_NAME|ALIAS" -s 01-01-2014 -e 30-01-2014 -m pdf

# output an invoice for specified client to the terminal in HTML
lewt invoice "CLIENT_NAME|ALIAS" -s 01-01-2014 -e 30-01-2014 -o -m html

```

LEWT is based around a systems loop called **Extract, Render, Process**. The program always runs in this order - data is extracted from a source, it is processed, then it is formatted for output on render. All *extract, render, process* funtionality in LEWT is provided via extensions. LEWT ships with a few core extensions:

- Calander Time Keeping: Extracts invoicing data from iCal, Google Calander sources.
- Billing: Processes invoices
- Liquid Renderer: Allows templated rendering of plain text, HTML, and PDF invoices using liquid templating markup.

It's pretty easy to create you own extension [even if it is currently unelegant, soz first dive at ruby;] all you need to do is create a folder in your extensions directory with a *.rb* file in it with the same name as the parent directory. This directory will house all your extension code, the naming conventioned is used for initialisation.

```
# Minimal Extension Implementation


```

You can specify some basic config for your LEWT deployment in the ```./lib/config``` directory.









