# Developer Thoughts

Whilst the system is now working I am still not satisfied with it. The project goal of composability has not been achieved yet.
I think this is partly due to what *composability* meaning actually is in the context of software accounting.

What would be generally useful if extracted data from various sources could be interpreted by any sort of processor by adhering to a pre-specified format
or in accounting lingo a general ledger. 

## The General Leger

The magic lays in specifying the general ledger format. This format should adhere to debit/credit norms and look roughly something like this:

| Date Start | Date End | Category | Entity | Description | Amount |


The dates would be date times and could be potentially combined into a range. Entity is the person/organization LEWT is transacting with. Amount can be positive or negative to indicate debit/credit.

By specifying this kind of data, processors can reliably interpret data from different extraction sources without knowing about them in advance. This supports the composability principle much better than
the current setup. The general ledger could be passed between the program run time stages in a YAML format to keep things simple.

## Command Line Interface

LEWT's CLI is flawed! Whilst options parsing is nice name-space conflicts will inevitably arise in LEWT implementations that run a lot of extensions. There are only 26 letters in the alphabet and I want
there to be more plugins than that, they can't all --name-space-it just to have reliable options parsing!

Nay. Extensions should have limited access to options.

### Extractors
Extractors should be able to define some sort of CL option for LEWT's -x opt. They should also have access to LEWT's -s & -e opts so that they can work upon specific date-time ranges. In end effect
they would be invoked as such:

```
lewt -x gcal|expenses|... # rest ommitted
```

In this way extractors could be chained together to create a general ledger for the processors to analyze.

### Processors

Processors will not be able to set options via the command line. Instead they will respond to the -p opt in much the same way as extractors respond to the -x opt.

Processors will be passed the general ledger data from the extraction stage upon which they can work upon and further add too. This data is passed into the processor as a YAML string format however the
processor super class should automatically serialize it into the **general ledger hash* for the processor to work upon.

```
gleger = {
	date_start => ...,
	date_end => ...,
	category => ...,
	entity => ...,
	description => ...,
	amount => ...
}
```
The reason data should be passed into the processor as a YAML string (and from the processor to the renderer in general) is so that STD OUT output from other CL programs can potentially be piped into LEWT tools.
Data could be read in a while loop somewhere in the extension super class hierarchy (only when the user pipes of course), serialized and passed onto the extension.

The processor will surrender its working data as a YAML string for the renderer to further interpret, it will serialize this data in the same way.

### Renderers

Renderers receive the YAML data and have it auto-serialized in much the same way as processors. Rendereres will output the processed data in some pre-agreed upon format. They will respond to the -r
command line option the same way as the other extensions.

It is up to a renderer to decide which items of the general ledger it will output. The template of the Liquid Renderer LEWT extension for invoices might look something like this.

```
<h2>Items:</h2>
<table>
{% if ( row.category == 'billable' ) %}
	<tr>
		...
	</tr>
{% endif %}
</table> 
```

The render will choose to respond to certain categories of ledger items or whatever passed on what is passed to it. The general ledger system is simple enough that extension developers can get there code around interpreting
arbitrary entries in it.

## The Big Picture

Data is passed between the *extract, process, render* stages as a YAML string and serialized into a hash by a super class.

Data is extracted into the *general ledger* format. Processors work on this general ledger data, adding there own. Renderers interpret it and output it to the desired formats.










