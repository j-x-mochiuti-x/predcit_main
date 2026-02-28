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
engine_app = sa.create_engine("sqlite:///../../data/loyalty-system/database.db")
engine_analitycal = sa.create_engine("sqlite:///../../data/analytics/database.db")
# %%
df = pd.read_sql(query, engine_app)

df.to_sql('life_cycle.sql', engine_analitycal, index=False, if_exists='append')
# %%
