Most of the packages we will be using are native to Python 3, however we will be installing two important additions:
Openpyxl which allows Python to easily read and write in excel files
And google_play_scraper an API designed for easily scraping data from the google play store

You can either install the packages from a jupyter notebook like the one I am using or you can choose to install from the Command Prompt.
If you decide to install from the Command Prompt, make sure to omit the ! in front of pip install. So for Command Prompt it would just be "pip install google_play scraper" and for the jupyter notebook it is "!pip install google_play_scraper".


```python
!pip install google_play_scraper
!pip install openpyxl
```

The rest of the tools we'll be using that are native to Python are: 

Pandas a very strong data analysis tool used for data structuring and manipulation
Pprint is a module for printing data structures which can be used as input to the interpreter
Datetime module is for manipulating dates and times
Tzlocal is a module for obtaining local time zones
Sqlite3 is a lightweight disk-based relational database built into Python
Random is used to generate random numbers
Time is used to provide many ways of representing time in code

We will now import all these packages:


```python
import pandas as pd
from google_play_scraper import app, Sort, reviews
from pprint import pprint
import datetime as dt
from tzlocal import get_localzone
import random
import time
import openpyxl
import sqlite3
```

Next we will be using SQLite to create an in-memory database where we can store our batches of reviews as the scraper continues running
An in-memory database means that the database is only stored on our RAM, the response is faster, however the database is temporary and as soon as you close this session, all the data will be lost. This is fine for our needs because we just need to use the database as a place to temporarily store reviews - Since our scraper is set up to work in a loop of only 200 reviews per batch, we need a place to put the data, as we go back to repeat the loop to scrape more reviews for the next batch.
Our SQLite database will serve its purpose by holding onto all the reviews we collect, until we're ready to save the data to a csv or json file.
If you want to keep your data stored in your SQL database, then you will need to change the line of code from :memory: to databasename.db instead.


```python
conn = sqlite3.connect(':memory:')
c = conn.cursor()
```

The cursor function (shown above) in sqlite allows us to execute SQL commands from within Python. We rename it as c for ease of use.

In the next chunk of code below, we create a table in our SQL database called review_collection. Since google application data comes with a dictionary, we use that to create our column names and we use blob as the datatype. We commit the changes with the commit function.


```python
c.execute('''CREATE TABLE review_collection (reviewId blob, userName blob, userImage blob, content blob, score blob, thumbsUpCount blob, reviewCreatedVersion blob, at blob, replyContent blob, repliedAt blob, app_name blob, app_id blob)''')
conn.commit()
```

Next we need to read in our excel spreadsheet, Emergency Com Data (if you're a student of Dr. Bonaretti) or whatever the file may be into a pandas dataframe.
We use the head function to take a look at our data.


```python
app_df = pd.read_excel(r'C:\Users\recon\Desktop\Emergency Com Dataa.xlsx')
app_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>AppID</th>
      <th>AppName</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>com.jupiterapps.earthquake</td>
      <td>3D Earthquake</td>
    </tr>
    <tr>
      <th>1</th>
      <td>ca.ab.gov.aea</td>
      <td>Alberta Emergency Alert</td>
    </tr>
    <tr>
      <th>2</th>
      <td>gov.fema.mobile.android</td>
      <td>FEMA</td>
    </tr>
  </tbody>
</table>
</div>



Next we assign names to our list of lists or each column in our dataframe.


```python
app_names = list(app_df['AppName'])
app_ids = list(app_df['AppID'])
```

We create a for loop to iterate through each of our app_ids, take the data and add it to a newly created app_info list object.
We print at the end to get a view of the data that was collected.


```python
app_info = []
for i in app_ids:
    info = app(i)
    del info['comments']
    app_info.append(info)

pprint(app_info[0])
```

Since we already scraped all of the metadata for all the apps, we go ahead and load the app_info list into a pandas dataframe and take a look and the data inside.


```python
info_collection = pd.DataFrame(app_info)
info_collection.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>title</th>
      <th>description</th>
      <th>descriptionHTML</th>
      <th>summary</th>
      <th>summaryHTML</th>
      <th>installs</th>
      <th>minInstalls</th>
      <th>score</th>
      <th>ratings</th>
      <th>reviews</th>
      <th>...</th>
      <th>released</th>
      <th>updated</th>
      <th>version</th>
      <th>recentChanges</th>
      <th>recentChangesHTML</th>
      <th>editorsChoice</th>
      <th>similarApps</th>
      <th>moreByDeveloper</th>
      <th>appId</th>
      <th>url</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>[]</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>...</td>
      <td>None</td>
      <td>None</td>
      <td>[None, CnQKcgpwMCwxMDAwMDAwLjE3MzgzMTQ3NzgsODU...</td>
      <td>None</td>
      <td>None</td>
      <td>False</td>
      <td>None</td>
      <td>None</td>
      <td>com.jupiterapps.earthquake</td>
      <td>https://play.google.com/store/apps/details?id=...</td>
    </tr>
    <tr>
      <th>1</th>
      <td>[]</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>...</td>
      <td>None</td>
      <td>None</td>
      <td>[None, CmcKZQpjMCwxMDAwMDAwLjIyNzc1NTYyMTEsNzc...</td>
      <td>None</td>
      <td>None</td>
      <td>False</td>
      <td>None</td>
      <td>None</td>
      <td>ca.ab.gov.aea</td>
      <td>https://play.google.com/store/apps/details?id=...</td>
    </tr>
    <tr>
      <th>2</th>
      <td>[]</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>None</td>
      <td>...</td>
      <td>None</td>
      <td>None</td>
      <td>[None, CnEKbwptMCwxMDAwMDAwLjQ1Mjk3MDU2NDQsNDA...</td>
      <td>None</td>
      <td>None</td>
      <td>False</td>
      <td>None</td>
      <td>None</td>
      <td>gov.fema.mobile.android</td>
      <td>https://play.google.com/store/apps/details?id=...</td>
    </tr>
  </tbody>
</table>
<p>3 rows × 51 columns</p>
</div>



If the data looks good, you can go ahead and save app_info to csv.


```python
info_collection.to_csv(r'C:\Users\recon\Desktop\info_collection.csv')
```

The next large chunk of code contains 5 for loops and several if statements, this is our code for scraping the reviews and storing them in our SQL database.
Look out for the notes from me by the #s.
Essentially what the code is doing is iterating through the list of app names, at each app name it scrapes all the reviews until it reaches 200 which makes a batch, it waits 5 seconds then continues to scrape from that same app until it has scraped all the reviews. The reason we do this is because the google play store page only loads 200 reviews at a time, in order to view the rest one must click and load another 200 more... Our code is basically clicking for us, waiting 5 seconds for it to load then continuing to scrape.


```python
for app_name, app_id in zip(app_names, app_ids):
    
    
    start = dt.datetime.now(tz=get_localzone())
    fmt= "%m/%d/%y - %T %p"    
    
    
    print('---'*20)
    print('---'*20)    
    print(f'***** {app_name} started at {start.strftime(fmt)}')
    print()
    
    
    app_reviews = []
    
    
    count = 200
    
    
    batch_num = 0
    
    
    
    rvws, token = reviews(
        app_id,           
        lang='en',        
        country='us',     
        sort=Sort.NEWEST, 
        count=count       
    )
    
    
    
    for r in rvws:
        r['app_name'] = app_name 
        r['app_id'] = app_id     
     
    
    
    app_reviews.extend(rvws)
    
    
    batch_num +=1 
    print(f'Batch {batch_num} completed.')
    
    
    time.sleep(random.randint(1,5))
    
    
    
    
    pre_review_ids = []
    for rvw in app_reviews:
        pre_review_ids.append(rvw['reviewId'])
    
    
    
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
        
        
          
        all_review_ids = pre_review_ids + new_review_ids
        if len(set(pre_review_ids)) == len(set(all_review_ids)):
            print(f'No reviews left to scrape. Completed {batch_num} batches.\n')
            break
        
         
          
        pre_review_ids = all_review_ids
        
        
        
        if batch_num%100==0:
            
            
            print(f'Batch {batch_num} completed.')
            
            #Next we will insert the reviews we just scraped into our SQL database and commit the changes
            c.executemany("INSERT INTO review_collection VALUES (:reviewId, :userName, :userImage, :content, :score, :thumbsUpCount, :reviewCreatedVersion, :at, :replyContent, :repliedAt, :app_name, :app_id)", app_reviews)
            conn.commit()
            
            store_time = dt.datetime.now(tz=get_localzone())
            print(f"""
            Successfully inserted {len(app_reviews)} {app_name} 
            reviews into collection at {store_time.strftime(fmt)}.\n
            """)
            
            
            app_reviews = []
        
        
        time.sleep(random.randint(1,5))
      
    
    
      
    print(f'Done scraping {app_name}.')
    print(f'Scraped a total of {len(set(pre_review_ids))} unique reviews.\n')
    
    
    #Insert the remaining reviews into our database
    c.executemany("INSERT INTO review_collection VALUES (:reviewId, :userName, :userImage, :content, :score, :thumbsUpCount, :reviewCreatedVersion, :at, :replyContent, :repliedAt, :app_name, :app_id)", app_reviews)
    conn.commit()
    
    end = dt.datetime.now(tz=get_localzone())
    
    
    print(f"""
    Successfully inserted all {app_name} reviews into collection
    at {end.strftime(fmt)}.\n
    """)
    print(f'Time elapsed for {app_name}: {end-start}')
    print('---'*20)
    print('---'*20)
    print('\n')
    
    
    time.sleep(random.randint(1,5))

```

    ------------------------------------------------------------
    ------------------------------------------------------------
    ***** 3D Earthquake started at 11/02/22 - 01:49:24 AM
    
    Batch 1 completed.
    No reviews left to scrape. Completed 9 batches.
    
    Done scraping 3D Earthquake.
    Scraped a total of 1565 unique reviews.
    
    
        Successfully inserted all 3D Earthquake reviews into collection
        at 11/02/22 - 01:49:50 AM.
    
        
    Time elapsed for 3D Earthquake: 0:00:26.434846
    ------------------------------------------------------------
    ------------------------------------------------------------
    
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    ***** Alberta Emergency Alert started at 11/02/22 - 01:49:52 AM
    
    Batch 1 completed.
    No reviews left to scrape. Completed 5 batches.
    
    Done scraping Alberta Emergency Alert.
    Scraped a total of 731 unique reviews.
    
    
        Successfully inserted all Alberta Emergency Alert reviews into collection
        at 11/02/22 - 01:50:05 AM.
    
        
    Time elapsed for Alberta Emergency Alert: 0:00:12.560768
    ------------------------------------------------------------
    ------------------------------------------------------------
    
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    ***** FEMA started at 11/02/22 - 01:50:08 AM
    
    Batch 1 completed.
    No reviews left to scrape. Completed 7 batches.
    
    Done scraping FEMA.
    Scraped a total of 1173 unique reviews.
    
    
        Successfully inserted all FEMA reviews into collection
        at 11/02/22 - 01:50:27 AM.
    
        
    Time elapsed for FEMA: 0:00:19.520670
    ------------------------------------------------------------
    ------------------------------------------------------------
    
    
    

You should be able to watch as the code will print as it scrapes through each app, what time it started scraping, what time it ended scraping, how many batches, when they are successfully inserted into the database and how long it took to scrape each app.

After the code has finished running, which may take several hours depending upon how much data there is, we will take a peek at our data in our SQL database with the following code:


```python
for row in c.execute('SELECT * FROM review_collection WHERE rowid  < 5'):
    print(row)
```

    ('62c4729a-2ca5-4891-bcce-19e552ac019b', 'Sean Cooper', 'https://play-lh.googleusercontent.com/a/ALm5wu2apUtR7Cx_dfFrmCSxLyqws-WcdIBY_uBJjGAO=mo', 'Good app', 5, 0, '1.25', '2022-10-31 20:51:39', None, None, '3D Earthquake', 'com.jupiterapps.earthquake')
    ('d3100aa4-fe73-4ae2-a1fe-994851d7c9a0', 'Paul Gonzalez', 'https://play-lh.googleusercontent.com/a/ALm5wu0jh3fxlccaFOb1-mTHarJm7SN7mRZzsI-z_mnJ=mo', 'It locked me I use my imagination when it comes to 3D and my own ideas what I see what I think whatever you never know', 5, 0, '1.25', '2022-10-09 20:17:50', None, None, '3D Earthquake', 'com.jupiterapps.earthquake')
    ('22014d28-3c98-4c18-976d-1d2aa5b26592', 'Felix Soap', 'https://play-lh.googleusercontent.com/a/ALm5wu0gw6Xx2nME9SfCVx-vvOtWvaVrxiVHaDUfYbeZ=mo', 'Excellent tool', 5, 0, '1.25', '2022-09-28 18:30:14', None, None, '3D Earthquake', 'com.jupiterapps.earthquake')
    ('8bbc4a95-6b1d-444a-b20d-b9c47aaa644e', 'OTHER-TERRESTRIAL LIFE FORM', 'https://play-lh.googleusercontent.com/a-/ACNPEu9JicyK3fe2TRud3Zx_z6c-_ryV5RHe1zFMPtMwgg', "DOESN'T WORK! It has ceased to function, I get absolutely nothing in the way of information from this app now,I paid for this app,by the way.", 1, 9, '1.25', '2022-09-22 11:39:51', None, None, '3D Earthquake', 'com.jupiterapps.earthquake')
    


```python
for row in c.execute('SELECT * FROM review_collection;'):
    print(row)
```

If everything looks good, we will move forward and pull our data from our SQL database and load it into a pandas dataframe.


```python
check_df = pd.read_sql("SELECT * FROM review_collection", conn)
check_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>reviewId</th>
      <th>userName</th>
      <th>userImage</th>
      <th>content</th>
      <th>score</th>
      <th>thumbsUpCount</th>
      <th>reviewCreatedVersion</th>
      <th>at</th>
      <th>replyContent</th>
      <th>repliedAt</th>
      <th>app_name</th>
      <th>app_id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>62c4729a-2ca5-4891-bcce-19e552ac019b</td>
      <td>Sean Cooper</td>
      <td>https://play-lh.googleusercontent.com/a/ALm5wu...</td>
      <td>Good app</td>
      <td>5</td>
      <td>0</td>
      <td>1.25</td>
      <td>2022-10-31 20:51:39</td>
      <td>None</td>
      <td>None</td>
      <td>3D Earthquake</td>
      <td>com.jupiterapps.earthquake</td>
    </tr>
    <tr>
      <th>1</th>
      <td>d3100aa4-fe73-4ae2-a1fe-994851d7c9a0</td>
      <td>Paul Gonzalez</td>
      <td>https://play-lh.googleusercontent.com/a/ALm5wu...</td>
      <td>It locked me I use my imagination when it come...</td>
      <td>5</td>
      <td>0</td>
      <td>1.25</td>
      <td>2022-10-09 20:17:50</td>
      <td>None</td>
      <td>None</td>
      <td>3D Earthquake</td>
      <td>com.jupiterapps.earthquake</td>
    </tr>
    <tr>
      <th>2</th>
      <td>22014d28-3c98-4c18-976d-1d2aa5b26592</td>
      <td>Felix Soap</td>
      <td>https://play-lh.googleusercontent.com/a/ALm5wu...</td>
      <td>Excellent tool</td>
      <td>5</td>
      <td>0</td>
      <td>1.25</td>
      <td>2022-09-28 18:30:14</td>
      <td>None</td>
      <td>None</td>
      <td>3D Earthquake</td>
      <td>com.jupiterapps.earthquake</td>
    </tr>
    <tr>
      <th>3</th>
      <td>8bbc4a95-6b1d-444a-b20d-b9c47aaa644e</td>
      <td>OTHER-TERRESTRIAL LIFE FORM</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>DOESN'T WORK! It has ceased to function, I get...</td>
      <td>1</td>
      <td>9</td>
      <td>1.25</td>
      <td>2022-09-22 11:39:51</td>
      <td>None</td>
      <td>None</td>
      <td>3D Earthquake</td>
      <td>com.jupiterapps.earthquake</td>
    </tr>
    <tr>
      <th>4</th>
      <td>7eaa260f-1de5-4cc5-8e4d-b425f63b2031</td>
      <td>Arturo Garay</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>I don't have a good reason to keep this app, i...</td>
      <td>3</td>
      <td>2</td>
      <td>1.25</td>
      <td>2022-09-19 14:36:44</td>
      <td>None</td>
      <td>None</td>
      <td>3D Earthquake</td>
      <td>com.jupiterapps.earthquake</td>
    </tr>
  </tbody>
</table>
</div>



If you are well versed in SQL, you can use all kinds of SQL queries for your data.
Here is an example of pulling only reviews from the FEMA app from SQL database and loading it into a dataframe.


```python
test_df = pd.read_sql("SELECT * FROM review_collection WHERE app_name = 'FEMA'", conn)
test_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>reviewId</th>
      <th>userName</th>
      <th>userImage</th>
      <th>content</th>
      <th>score</th>
      <th>thumbsUpCount</th>
      <th>reviewCreatedVersion</th>
      <th>at</th>
      <th>replyContent</th>
      <th>repliedAt</th>
      <th>app_name</th>
      <th>app_id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0031e229-7a35-4aa2-a886-a61e8246f167</td>
      <td>Zuleika Solares</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>Easy to use and understand.</td>
      <td>5</td>
      <td>0</td>
      <td>3.0.8</td>
      <td>2022-10-29 23:06:37</td>
      <td>None</td>
      <td>None</td>
      <td>FEMA</td>
      <td>gov.fema.mobile.android</td>
    </tr>
    <tr>
      <th>1</th>
      <td>f45b5436-8b87-4476-8677-195c4627fb1a</td>
      <td>Dawn Lord</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>Downloaded the app,tried to enter location. I ...</td>
      <td>1</td>
      <td>0</td>
      <td>None</td>
      <td>2022-10-27 17:00:31</td>
      <td>None</td>
      <td>None</td>
      <td>FEMA</td>
      <td>gov.fema.mobile.android</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3f5b7f31-7f55-4367-9f33-9fd607262088</td>
      <td>Sherry Gilley</td>
      <td>https://play-lh.googleusercontent.com/a/ALm5wu...</td>
      <td>Long</td>
      <td>5</td>
      <td>0</td>
      <td>3.0.8</td>
      <td>2022-10-23 18:32:00</td>
      <td>None</td>
      <td>None</td>
      <td>FEMA</td>
      <td>gov.fema.mobile.android</td>
    </tr>
    <tr>
      <th>3</th>
      <td>37fe3aaf-ffc2-48dc-bef9-a2357990fec8</td>
      <td>IrishRose (PixieDoll)</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>I opened the app and it is all in Spanish and ...</td>
      <td>2</td>
      <td>0</td>
      <td>3.0.8</td>
      <td>2022-10-23 05:15:29</td>
      <td>None</td>
      <td>None</td>
      <td>FEMA</td>
      <td>gov.fema.mobile.android</td>
    </tr>
    <tr>
      <th>4</th>
      <td>083594a5-c776-49da-be96-62802f1e1670</td>
      <td>julie guy</td>
      <td>https://play-lh.googleusercontent.com/a-/ACNPE...</td>
      <td>Behind on the news hours after things had hit ...</td>
      <td>3</td>
      <td>0</td>
      <td>None</td>
      <td>2022-10-22 16:11:38</td>
      <td>None</td>
      <td>None</td>
      <td>FEMA</td>
      <td>gov.fema.mobile.android</td>
    </tr>
  </tbody>
</table>
</div>



Now that you have loaded your pandas dataframe with the review data from our SQL database, we can save to csv or json file


```python
check_df.to_csv(r'C:\Users\recon\Desktop\review_collection.csv')
```


```python
check_df.to_json(r'C:\Users\recon\Desktop\review_collection.json')
```

Finally, don't forget to close your SQL connection.


```python
conn.close()
```
