# DROP TABLES

songplay_table_drop = "drop table if exists songplay"
user_table_drop = "drop table if exists users"
song_table_drop = "drop table if exists songs"
artist_table_drop = "drop table if exists artists"
time_table_drop = "drop table if exists time"

# CREATE TABLES

songplay_table_create = ("""create table if not exists songplays
(songplay_id serial primary key, start_time bigint not null, user_id int not null, level varchar not null, song_id varchar,
artist_id varchar, session_id int not null, location varchar not null, user_agent varchar not null)
""")

user_table_create = ("""create table if not exists users
(user_id int primary key, first_name varchar not null, last_name varchar not null, gender varchar not null, level varchar not null)
""")

song_table_create = ("""create table if not exists songs
(song_id varchar primary key, title varchar not null, artist_id varchar not null, year int not null, duration numeric not null)
""")

artist_table_create = ("""create table if not exists artists
(artist_id varchar primary key, name varchar not null, location varchar not null, latitude float not null, longitude float not null)
""")

time_table_create = ("""create table if not exists time
(start_time bigint primary key, hour int not null, day int not null, week int not null, month int not null, year int not null,
weekday varchar not null)""")

# INSERT RECORDS

songplay_table_insert = ("""insert into songplays (start_time, user_id, level, song_id,
artist_id, session_id, location, user_agent)
values (%s, %s, %s, %s, %s, %s, %s, %s)
""")

# Insert into Users table
# If constraint is encountered, update non-key columns, with assumption that newer data has more 'up-to-date' data
user_table_insert = ("""insert into users (user_id, first_name, last_name, gender, level)
values (%s, %s, %s, %s, %s)
on conflict on constraint users_pkey do update
set (first_name, last_name, gender, level) = (EXCLUDED.first_name, EXCLUDED.last_name, EXCLUDED.gender, EXCLUDED.level)""")

song_table_insert = ("""insert into songs (song_id, title, artist_id, year, duration)
values (%s, %s, %s, %s, %s)""")

# Insert into Artists table
# If constraint is encountered, update non-key columns, with assumption that newer data has more 'up-to-date' data
artist_table_insert = ("""insert into artists (artist_id, name, location, latitude, longitude)
values (%s, %s, %s, %s, %s)
on conflict on constraint artists_pkey do update
set (name, location, latitude, longitude) = (EXCLUDED.name, EXCLUDED.location, EXCLUDED.latitude, EXCLUDED.longitude)""")

# Insert into Artists table
# Do nothing if PK constraint is triggered - data cannot be 'more correct'
time_table_insert = ("""insert into time (start_time, hour, day, week, month, year, weekday)
values (%s, %s, %s, %s, %s, %s, %s)
on conflict on constraint time_pkey do nothing""")

# FIND SONGS
# song ID and artist ID based on the title, artist name, and duration of a song
song_select = ("""select songs.song_id, artists.artist_id
from songs join artists on songs.artist_id = artists.artist_id
where songs.title = %s
and artists.name = %s
and songs.duration = %s
""")

# QUERY LISTS

create_table_queries = [songplay_table_create, user_table_create, song_table_create, artist_table_create, time_table_create]
drop_table_queries = [songplay_table_drop, user_table_drop, song_table_drop, artist_table_drop, time_table_drop]