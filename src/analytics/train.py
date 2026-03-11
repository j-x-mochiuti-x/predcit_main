# %%
import pandas as pd
import sqlalchemy as sa

con = sa.create_engine("sqlite:///../../data/analytics/database.db")
# %%
#importaçã dos dados

df = pd.read_sql("abt_fiel", con)
df.head()
# %%
