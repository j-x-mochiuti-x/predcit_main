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

#EXPLORE (Exploração) -  faltantes
s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas>0]
s_nas

#EXPLORE (Exploração) -  BIVARIADA
cat_features = ['descLifeCycleAtual', 'descLifeCycleD28']
num_features = list(set(features) - set(cat_features))

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

bivariada = df_train.groupby(target)[num_features].median()
bivariada['ratio'] = (bivariada[1]+0.001) / (bivariada[0]+0.001)
bivariada = bivariada.sort_values(by='ratio', ascending=False)
bivariada

# %%
df_train.groupby('descLifeCycleAtual')[target].mean()

# %%
df_train.groupby('descLifeCycleD28')[target].mean()

# %%
# MODIFY (Modificação) - Remoção

X_train[num_features] = X_train[num_features].astype(float)

to_remove = bivariada[bivariada['ratio']==1].index.tolist()
drop_features = selection.DropFeatures(to_remove)

#%%
# MODIFY - Faltantes

fill_0 = ['github2025', 'python2025']
imput_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0,
                                            variables=fill_0)

imput_new = imputation.CategoricalImputer(
    fill_value='Nao-Usuario',
    variables=['descLifeCycleD28'])

imput_1000 = imputation.ArbitraryNumberImputer(
    arbitrary_number=1000,
    variables=['avgIntervaloDiasVida',
            'avgIntervaloDiasD28',
            'qtdDiasUltiAtividade'],
    )

#%%
# MODIFY - ONEHOT enconding

onehot = encoding.OneHotEncoder(variables=cat_features)

#%%
# Aplicando modificação no dataset

X_train_transform = drop_features.fit_transform(X_train)
X_train_transform = imput_0.fit_transform(X_train_transform)
X_train_transform = imput_new.fit_transform(X_train_transform)
X_train_transform = imput_1000.fit_transform(X_train_transform)
X_train_transform = onehot.fit_transform(X_train_transform)

#%% MODEL (Modelagem)
from sklearn import tree

model = tree.DecisionTreeClassifier(random_state=42, max_leaf_nodes=50)
model.fit(X_train_transform, y_train)

#%%

#ASSESS (verificação)
from sklearn import metrics

y_pred_train = model.predict(X_train_transform)
acc_train = metrics.accuracy_score(y_train, y_pred_train)

print(f"Acurácia treino: {acc_train}")

#%%

X_test_transform = drop_features.transform(X_test)
X_test_transform = imput_0.transform(X_test_transform)
X_test_transform = imput_new.transform(X_test_transform)
X_test_transform = imput_1000.transform(X_test_transform)
X_test_transform = onehot.transform(X_test_transform)

y_pred_test = model.predict(X_test_transform)
acc_test = metrics.accuracy_score(y_test, y_pred_test)
print(f"Acurácia teste: {acc_test}")