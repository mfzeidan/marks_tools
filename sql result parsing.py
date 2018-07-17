import pymssql
import itertools
server = "52.232.179.164:666"
user = "Mark"
password = "CoventGarden1"
db = 'GMU_Opioids'
port = 666
conn = pymssql.connect(server=server, user=user, password=password, database=db, port=port)
cursor = conn.cursor()

query = """SELECT TOP (1) [drug_name]
    ,[total_day_supply]
    FROM [gmu data - raw].[dbo].[total_day_supply_by_drug]"""



cursor.execute(query)
print("---------")
desc = cursor.description
column_names = [col[0] for col in desc]
data1 = [dict(zip(column_names, row))  
        for row in cursor.fetchall()]
print(data1)
print("---------") 



query2 = """SELECT
  *
FROM
  INFORMATION_SCHEMA.TABLES;
    FROM [gmu data - raw].[dbo].[total_day_supply_by_drug]"""


cursor.execute(query2)
print("---------")
desc = cursor.description
column_names = [col[0] for col in desc]
data2 = [dict(zip(column_names, row))  
        for row in cursor.fetchall()]
print(data2)
print("---------") 

def dict_compare(d1, d2):
    d1_keys = set(d1.keys())
    d2_keys = set(d2.keys())
    intersect_keys = d1_keys.intersection(d2_keys)
    added = d1_keys - d2_keys
    removed = d2_keys - d1_keys
    modified = {o : (d1[o], d2[o]) for o in intersect_keys if d1[o] != d2[o]}
    same = set(o for o in intersect_keys if d1[o] == d2[o])
    return added, removed, modified, same


added, removed, modified, same = dict_compare(data1, data2)

print(row)
