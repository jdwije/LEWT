LEWT
====
*Lazy Enterprise for hackers Without Time*

LEWT is a command line program that lets you parse your .ical files and extract time based work data from them, then output that information to invoices, reports, or whatever else you like. This allows you to define the hours you worked in a graphical calendar application (of your choice) and setup some general rules for different clients to greatly expediate your invoicing & accounting workflow.

It is designed for folks who bill hourly for there work and are who struggle to keep there accounting in order.

This new project is currently under active development and can be considered ALPHA release software. It might not work on your machine.

More to follow soon.

## Command Line Usage

LEWT aim's to have a *natural sounding* command line API to make it easy and intuitative to use. It also aims to allow you to do *more* things with your enterprise data such as piping it into other programs or piping other programs into it.

Here are some example CL's.

```
# Generate an invoice for past week for client with alias 'XWB' and store it to the LEWT-Stash. Outputs YAML to console.
lewt invoice client XWB

# As above but for all clients or a subset specified as 'TTS|MD|XXX'.
lewt invoice clients

# Same but for one client and in specified date range.
lewt invoice client XWB from 01-05-2014 till 29-05-2014

# Send latest LEWT stash invoice to client. Format HTML email and attach a PDF copy to it, plain text is always there by default. Outputs send status to console.
lewt email client TTS invoice as html|pdf

# Generates a general business report.
lewt report on business

# Generates a client specific report.
lewt report on client TTS

# So for multiple. notice the pluralisation.
lewt report on clients TTS|MD|AA

# Gets invoices from the LEWT store that match the specified criteria.
lewt get invoices matching client TTS|MD and from > 01-01-2013

# Email arbitrary data to a client.
lewt email client TTS with message "hey mate please check this out..." and subject "the latest gprp report" and attachment as PDF from pipe | wget http://www.something.com.au

```

## Basic Setup

There are several config files you will need to tailor to your enterprise before we get started.

See ```config/clients.yaml``` to configure your client settings, example usage is shown inside the file.




