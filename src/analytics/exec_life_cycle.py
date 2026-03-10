# %%
import pandas as pd
import sqlalchemy as sa
import datetime
from tqdm import tqdm

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

def date_range(start, stop):
    dates =[]
    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')
    return dates

dates = date_range('2024-03-01', '2025-09-01')

for i in tqdm(dates):

    with engine_analitycal.connect() as con:
        try:
            query_delete = f"DELETE FROM life_cycle WHERE dtRef = date('{i}', '-1 day')"
            print(query_delete)
            con.execute(sa.text(query_delete))
            con.commit
        except Exception as e:
            print(e)
    
    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analitycal, index=False, if_exists="append")
# %%
