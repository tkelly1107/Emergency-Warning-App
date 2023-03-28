library(mongolite)
connection_string = 'mongodb+srv://admin@googlecluster.z2zrj.mongodb.net/app_proj_db'
review_collection = mongo(collection="review_collection", db="app_proj_db", url=connection_string)
review_collection$iterate()$one()
review_collection$remove('{}')
info_collection = mongo(collection="info_collection", db="app_proj_db", url=connection_string)
info_collection$iterate()$one()
info_collection$remove('{}')
