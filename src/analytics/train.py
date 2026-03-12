import pandas as pd
import sqlalchemy
from sklearn import model_selection
from feature_engine import selection
from feature_engine import encoding
from feature_engine import imputation

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

#%%
# SAMPLE (Amostragem) - Importando dados
df = pd.read_sql("SELECT * FROM abt_fiel", con)
df.head()

#%%