LIHT
====
***L**azy **I**nvoicing for **H**ackers without **T**ime*

LIHT is a command line program that lets you parse your .ical files and extract time based work data from them, then output that information to invoices, reports, or whatever else you like.

It is designed for freelancers or contractors who bill hourly for there work and are completely lazy with their accounting.

### How it Works.

**Screenshot of my weekly schedule**

Here is an example of my weekly work schedule. I maintain it in iCalendar which ships native with OSX. I simply define the hours I worked graphically, add some descriptions, and mention the client company in the summary.

**screenshot of terminal**

```liht xx-xx-20xx xx-xx-20xx```

one command outputs an invoice for this period. Because all of my client data is defined in a flat config file, the program simply reads the calender, extracts relevant information, and then performs some simple calculations. You can further pipe this command to other programs to for example auto email it out to your clients, or create a pdf and store it on disk.

```liht --report xx-xx-20xx xx-xx-20xx```

Compiles a report for the indicated time period based of your ```tax.yaml``` setup file.
