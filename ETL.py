import pandas as pd
from sqlalchemy import create_engine

USER = 'your_username'
PASSWORD = 'your_password'
HOST = 'localhost'
PORT = '3306'
DATABASE = 'wcstats'

connection_string = f"mysql+pymysql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}"
disk_engine = create_engine(connection_string)

def extract(endpoint):
    url = f"https://raw.githubusercontent.com/jfjelstul/worldcup/refs/heads/master/data-csv/{endpoint}.csv"
    df = pd.read_csv(url)
    return df

def transform_teams(df):
    df = df[["team_id", "team_name", "region_name"]]
    df.columns = ["id", "name", "region"]
    return df

def transform_players(df):
    position_col = ["goal_keeper", "defender", "midfielder", "forward"]
    df["position"] = df[position_col].idxmax(axis=1)                                                                                # Determine position base on which position column is True
    df = df.replace(["not available"], pd.NA)                                                                                       # Replace birth_date "not available" with Null
    df["latest_wc"] = df["list_tournaments"].apply(lambda x: max(map(int, str(x).split(","))) if pd.notna(x) else None)             # Find latest wc participated by finding the max year in list_tournaments
    df = df[["player_id", "family_name", "given_name", "birth_date", "count_tournaments", "list_tournaments", "latest_wc", "position"]]
    df.columns = ["id", "family_name", "given_name", "bod", "wc_counts", "list_of_wc", "latest_wc", "position"]
    return df

def transform_tournaments(df):
    df["type"] = df["year"].apply(lambda x: "Men" if x % 2 == 0 else "Women")
    df = df[["tournament_id", "year", "host_country", "winner", "count_teams", "type"]]
    df.columns = ["id", "year", "host", "winner", "no_of_teams", "type"]
    return df

def transform_matches(df):
    df = df[["match_id", "tournament_id", "stage_name", "home_team_id", "away_team_id", "result", "home_team_score", "away_team_score"]]
    df.columns = ["id", "tournament_id", "stage_name", "home_team_id", "away_team_id", "result", "home_score", "away_score"]
    return df

def transform_goals(df):
    df = df[["match_id", "team_id", "player_id", "minute_regulation", "own_goal", "penalty"]]
    df.columns = ["match_id", "team_id", "player_id", "minutes", "og", "pen"]
    return df

def transform_bookings(df):
    booking_col = ["yellow_card", "second_yellow_card", "red_card"]
    df["booking"] = df[booking_col].idxmax(axis=1)                                                                                   # Determine booking type based on which booking column is True
    df = df[["match_id", "team_id", "player_id", "minute_regulation", "booking"]]
    df.columns = ["match_id", "team_id", "player_id", "minutes", "booking"]
    return df

def load(df, table):
    df.to_sql(table, disk_engine, if_exists='append', index = False)

Tables = {
    "teams": transform_teams,
    "players": transform_players,
    "tournaments": transform_tournaments,
    "matches": transform_matches,
    "goals": transform_goals,
    "bookings": transform_bookings
}

for table, transform in Tables.items():
    df = extract(table)
    df = transform(df)
    load(df, table)