<sub>Python Version 3.9.2 64-Bit</sub>

# How to Use Google Play API Scraper for Python


## Setup
Packages:

**Pandas** is data analysis tool for data structuring and manipulation

**Google_play_scraper** is an API designed for Python to easily be used for extracting or mining data from Google Play Store

**Pprint** is a module for printing data structures which can be used as input to the interpreter

**Datetime** module is for manipulating dates and times

**Tzlocal** is a module for obtaining local time zones

**Openpyxl** is a Python package for reading and writing in Excel files


<sub>[random and time is part of Python base package so there should be no need to install these]</sub>

The Python file for this code can be found in the code folder as "googlereviewautoscraper.py"


## Install packages
Once you've installed Python, you're going to need to install the packages we'll be using. 
You'll need to open up the Command Prompt and enter:
```
pip install google_play_store
pip install pandas
pip install openpyxl
pip install tzlocal
pip install datetime
```
**Pandas, google_play_scraper, datetime, tzlocal, openpyxl**

Once they've been installed, you can import them into your Python shell.

```
import pandas as pd
from google_play_scraper import app, Sort, reviews
from pprint import pprint
import datetime as dt
from tzlocal import get_localzone
import random
import time
import openpyxl
```

### Prepare your Pandas Dataframe. 

review_collection will contain review data
info_collection will contain metadata
```
info_collection = pd.DataFrame()
review_collection = pd.DataFrame()
```


Before the next step, make sure that your excel file with the list of google applications is ready by ensuring it is only reading the app url.
## Get your App IDs
The app ID is within the url and it is the part that typically begins with "id=" and ends with "&".

[Example: The link for FEMA Google app is: "https://play.google.com/store/apps/details?id=gov.fema.mobile.android&hl=en_US&gl=US"
To extract the app ID from that, you would have: "gov.fema.mobile.android"]

<sub>A Python and R script has been written in the code files to easily extract the app ID from google url in the Emergency Com Data sheet. You can find it here (link will be provided)</sub>

Read in the list of google apps you want the scraper to pull from.
```
app_df = pd.read_excel(r'C:\PATH.xlsx')
#To see a view of the data in the excel file
app_df.head()
```
Say you have 15 apps in your list and you want to view all of them, just take the number of apps you have and insert that number here:
```
app_df.head(15)
```
It will print that number of rows so you can review your app list.

Great, now that you've had a chance to double-check your app IDs, you can move to the next step.

Here we assign names to two lists in our dataframe for app names and IDs
```
app_names = list(app_df['AppName'])
app_ids = list(app_df['AppID'])
```
# Building the scraper
We create our first for loop to iterate through app IDs to gather the apps info

Print the data to see what it looks like
```
app_info = []
for i in app_ids:
    info = app(i)
    del info['comments']
    app_info.append(info)

pprint(app_info[0])
```

We insert the info data into the info_collection dataframe, then print to see the data
```
info_collection = pd.DataFrame(app_info)
info_collection.head()
```
Now we will do the same thing but for the reviews and store them in the review collection dataframe

### Loop through apps to get reviews
```
for app_name, app_id in zip(app_names, app_ids):
    
    #get start time
    start = dt.datetime.now(tz=get_localzone())
    fmt= "%m/%d/%y - %T %p"    
    
    #print starting output for app
    print('---'*20)
    print('---'*20)    
    print(f'***** {app_name} started at {start.strftime(fmt)}')
    print()
    
    #empty list after storing reviews
    app_reviews = []
    
    # number of reviews scraped per batch
    count = 200
    
    # how many batches have been completed
    batch_num = 0
    
    
    #retrieve reviews and token
    rvws, token = reviews(
        app_id,           
        lang='en',        
        country='us',     
        sort=Sort.NEWEST, 
        count=count       
    )
    
    
    #for each review, add keys for app name and app ID
    for r in rvws:
        r['app_name'] = app_name 
        r['app_id'] = app_id     
     
    
    #add the list of reviews to overall list
    app_reviews.extend(rvws)
    
    #increase batch count by one
    batch_num +=1 
    print(f'Batch {batch_num} completed.')
    
    #Wait 1 to 5 seconds to start next batch
    time.sleep(random.randint(1,5))
```
Add review IDs to list before the next batch
```
pre_review_ids = []
for rvw in app_reviews:
        pre_review_ids.append(rvw['reviewId'])
```
Create a for loop that will go to the most max number of batches

```
for batch in range(4999):
        rvws, token = reviews( # store continuation_token
            app_id,
            lang='en',
            country='us',
            sort=Sort.NEWEST,
            count=count,
            # using token obtained from previous batch
            continuation_token=token
        )
        
        
        new_review_ids = []
        for r in rvws:
            new_review_ids.append(r['reviewId'])
            
            # And add keys for name and id to ea review dict
            r['app_name'] = app_name # add key for app's name
            r['app_id'] = app_id     # add key for app's id
     
        
        app_reviews.extend(rvws)
        
        
        batch_num +=1
        
        #Break loop and stop scraping for current app if most recent batch
          #did not add any new reviews
          
        all_review_ids = pre_review_ids + new_review_ids
        if len(set(pre_review_ids)) == len(set(all_review_ids)):
            print(f'No reviews left to scrape. Completed {batch_num} batches.\n')
            break
        
         
        # all_review_ids becomes pre_review_ids to check against 
        # for next batch
        pre_review_ids = all_review_ids
        
        
        #At every 100 batch
        if batch_num%100==0:
            
            #Print number of batches completed
            print(f'Batch {batch_num} completed.')
            
            #Insert reviews into pandas dataframe
            review_collection = pd.DataFrame(app_reviews)
            
            #Print the number of reviews inserted
            store_time = dt.datetime.now(tz=get_localzone())
            print(f"""
            Successfully inserted {len(app_reviews)} {app_name} 
            reviews into collection at {store_time.strftime(fmt)}.\n
            """)
            
            #Empty list for next batches
            app_reviews = []
        
        #Wait 1 to 5 sec to start next batch
        time.sleep(random.randint(1,5))
```
    
Print update when max number of batches has been reached or last batch didn't add new reviews

```
print(f'Done scraping {app_name}.')
print(f'Scraped a total of {len(set(pre_review_ids))} unique reviews.\n')
```
    
Insert remaining reviews into dataframe
    
```
review_collection = pd.DataFrame(app_reviews)
```
End time
    
```
end = dt.datetime.now(tz=get_localzone())
```
Get ending output for app
    
```
print(f"""
Successfully inserted all {app_name} reviews into collection
at {end.strftime(fmt)}.\n
""")
print(f'Time elapsed for {app_name}: {end-start}')
print('---'*20)
print('---'*20)
print('\n')
```
Wait 1 to 5 seconds to start scraping next app
```
time.sleep(random.randint(1,5))
```
After scraper has finished running (which may take hours depending on how much data and your computers processing speed), let's take a look at the data we've collected into our dataframes:
```
review_collection.head()
```
This should return a list of review data from our apps with the column labeled 'content' containing our review text. 
Now we can import both our review collection and info collection to either a CSV or json file. 
```
review_collection.to_csv(r'C:\PATH.csv')
info_collection.to_csv(r'C:\PATH.csv')
```
or
```
review_collection.to_json(r'C:\PATH.json')
info_collection.to_json(r'C:\PATH.json')
```

<sub>Troubleshooting: 
If the scraper errors off while beginning to scrape an app, the error is usually that there are no reviews in that app for it to scrape. Make sure all the apps you have listed actually have reviews in them to be scraped.</sub>

______________________________________________________________________________________________________________________________
<sub>This code was adapted from https://python.plainenglish.io/scraping-storing-google-play-app-reviews-with-python-5640c933c476</sub>
