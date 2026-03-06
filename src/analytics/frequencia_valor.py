#%%
import pandas as pd
import sqlalchemy

#%%
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")