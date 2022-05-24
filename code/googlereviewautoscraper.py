import pandas as pd
from google_play_scraper import app, Sort, reviews
from pprint import pprint
import pymongo
from pymongo import MongoClient
import datetime as dt
from tzlocal import get_localzone
import random
import time
import openpyxl

#Connect to MongoDB google cluster.
client = MongoClient("mongodb+srv://admin:MeltemINFP2020@googlecluster.z2zrj.mongodb.net")
app_proj_db = client['app_proj_db']
info_collection = app_proj_db['info_collection']
review_collection = app_proj_db['review_collection']
#Before reading in csv, make sure to separate app id from google url with r script in folder
app_df = pd.read_excel(r'C:\Users\recon\OneDrive - Nova Southeastern University\Emergency Communication data\Emergency Com Data.xlsx')
app_df.head()

app_names = list(app_df['App_Name'])
app_ids = list(app_df['AppID'])
#error occurrs here. investigate.
app_info = []
for i in app_ids:
    info = app(i)
    del info['comments']
    app_info.append(info)

pprint(app_info[0])

info_collection.insert_many(app_info)
info_df = pd.DataFrame(list(info_collection.find({})))
info_df.head()


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
            
            
            review_collection.insert_many(app_reviews)
            
            
            store_time = dt.datetime.now(tz=get_localzone())
            print(f"""
            Successfully inserted {len(app_reviews)} {app_name} 
            reviews into collection at {store_time.strftime(fmt)}.\n
            """)
            
            
            app_reviews = []
        
        
        time.sleep(random.randint(1,5))
      
    
    
      
    print(f'Done scraping {app_name}.')
    print(f'Scraped a total of {len(set(pre_review_ids))} unique reviews.\n')
    
    
    
    review_collection.insert_many(app_reviews)
    
    
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


