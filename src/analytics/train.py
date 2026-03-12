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
# SAMPLE (Amostragem) - OOT 
df_oot = df[df['dtRef']==df['dtRef'].max()].reset_index(drop=True)
df_oot

#%%
# SAMPLE (Amostragem) - Treino e teste
target = 'flFiel'
features = df.columnstolist()[3:]

df_train_test = df[df['dtRef']<df['dtRef'].max()].reset_index(drop=True)

y= df_train_test[target]
X= df_train_test[features]

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X,y,
    test_size=0.2,
    random_state=42,
    stratify=y,
)

print(f"BASE TREINO: {y_train.shape[0]} Unidades  /\ Tx. target {100*y_train.mean():.2f}%")
print(f"BASE TREINO: {y_test.shape[0]} Unidades  /\ Tx. target {100*y_test.mean():.2f}%")

#%%