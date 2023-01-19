# BtcAggregateVolume
A simple EA and Indicator pair that plots a histogram of aggregated Bitcoin volume scraped from Bitcoinity.org.

1. Add the indicator to the chart first. Then add the EA.

2. Give it a few seconds to update, the web scrape takes 2-4 seconds. Once complete, chart will update on next tick.

3. The program downloads a couple csv files to your hd and will overwrite them with each download. The links to the file sources depend on the timefram you are viewing    and are as follows:

     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=minute&t=b&timespan=24h
     
     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=hour&t=b&timespan=30d
     
     https://data.bitcoinity.org/export_data.csv?c=e&data_type=volume&r=day&t=b&timespan=2y
