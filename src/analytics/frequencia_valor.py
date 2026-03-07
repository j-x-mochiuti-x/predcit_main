#%%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt

#%%
# Abre conexão com o banco de dados transacional
engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")
# %%
def import_query(path):
    with open(path) as open_file:
        return open_file.read()

query = import_query('frequencia_valor.sql')
# %%
df = pd.read_sql(query, engine)
df.head()
df = df[df['qtdePontosPos']<4000]
# %%
plt.plot(df['qtdeFrequencia'], df['qtdePontosPos'], 'o')
plt.grid(True)
plt.xlabel('Frequência')
plt.ylabel('Quantidade de Pontos')
plt.show()
# %%
from sklearn import cluster
from sklearn import preprocessing

minmax = preprocessing.MaxAbsScaler()
X = minmax.fit_transform(df[['qtdeFrequencia','qtdePontosPos']])
kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)
kmean.fit(X)

df['cluster'] = kmean.labels_

df.groupby(by='cluster')['IdCliente'].count()
# %%
import seaborn as sns

sns.scatterplot(data=df,
                x='qtdeFrequencia',
                y='qtdePontosPos',
                hue='cluster',
                palette='Set1')
plt.grid()
# %%
