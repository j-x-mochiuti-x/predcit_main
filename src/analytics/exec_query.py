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

def date_range(start, stop):
    dates =[]
    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')
    return dates

def execute_query(table, database_origin, database_target, dt_start, dt_stop):
    engine_app = sa.create_engine(f"sqlite:///../../data/{database_origin}/database.db")
    engine_analitycal = sa.create_engine(f"sqlite:///../../data/{database_target}/database.db")

    query = import_query(f"{table}.sql")

    dates = date_range(dt_start, dt_stop)

    for i in tqdm(dates):

        with engine_analitycal.connect() as con:
            try:
                query_delete = f"DELETE FROM {table} WHERE dtRef = date('{i}', '-1 day')"
                print(query_delete)
                con.execute(sa.text(query_delete))
                con.commit
            except Exception as e:
                print(e)
        
        print(i)
        query_format = query.format(date=i)
        df = pd.read_sql(query_format, engine_app)
        df.to_sql(table, engine_analitycal, index=False, if_exists="append")

# %%
database_origin = 'loyalty-system'
database_target = 'analytics'
table = 'life_cycle'
dt_start = '2024-03-01'
dt_stop = '2025-09-01'