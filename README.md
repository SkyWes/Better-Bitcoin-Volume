# BtcAggregateVolume
<img src="https://user-images.githubusercontent.com/119025169/233169604-ab571eac-5640-4559-9066-7d056493b9cc.PNG" width=400 />

EA and Indicator pair that plots a histogram of Bitcoin volume aggregated from top exchanges with real volume (many exchanges have fake and useless volume) scraped from Bitcoinity.org. When grouping the data into higher timeframes, great care must be taken to unsure the data "lines up" with the correct bars. My algorithm converts the datetimes to the local time zone, and groups the data based on the time frame.

### Installation
I'm assuming you are already familiar with the Metatrader platform and have installed custom indicators before.
1. Add the indicator to the chart first. Then add the EA.

2. Give it a few seconds to update, the web scrape takes 2-4 seconds. Once complete, chart will update on next tick.

3. The program downloads a couple csv files to your hd and will overwrite them with each download. The links to the file sources depend on the timeframe you are viewing    and are as follows:

     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=minute&t=b&timespan=24h
     
     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=hour&t=b&timespan=30d
     
     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=day&t=b&timespan=2y

Limitations to be improved upon : 
1. Because the WebRequest() function in MQL5 is only available for use in Expert Advisors, it is required to communicate to the Indicator through a GlobalVariable. Hence the EA, Indicator pairing. If more than one instance of the EA is applied, there will be a conflict between instances due to identical file naming of the file downloads. This could be overcome by naming the file downloads with an appended random number generated with MathRand() or by simply numbering the files in sequence and checking for the existence of a file before initializing a new instance. 

2. Due to the limitations of the data being downloaded, a 30M chart for example will only have 46 bars. It may be desirable to allow more bars to accumulate if analysis depends on more than 46 bars. If however the timeframe is changed, all the accumulated data will be lost. An additional feature may be added that allows an accumulation to be saved in a file for recovery if a user is cycling through timeframes, accidentally changes timeframes, or the terminal is closed.
