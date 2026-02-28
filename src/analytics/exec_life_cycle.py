# %%
import pandas as pd
import sqlalchemy as sa

#%%
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query("life_cycle.sql")
print(query)
# %%
