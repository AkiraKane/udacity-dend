# Project 1 - Data Modeling with Postgres

Created a data model and star schema in PostgreSQL for the "Sparkify" startup to gain insights into how their users are interacting with Sparkify's music library. Sparkify's raw data is contained within multiple JSON files, and Pandas was used to perform ETL of that raw data into the PostgreSQL database.

## Running the ETL Python scripts
Create the database schema by runnning the create_tables.py script:
`python create_tables.py`

Load the JSON data into the newly created PostgreSQL tables:
`python etl.py`

## Database Schema and Tables
Sparkify Song Plays Analytics Database

### Songplays Table
#### Description
Fact Table containing information on every single song played in the Sparkify music library.

#### Columns
| Column Name | Description | Datatype |
| --- | --- | --- |
| songplay_id | Unique ID of each songplay | Serial - Primary Key |
| start_time | Start time in Unix epoch time of song play | Big Int |
| user_id | ID of User | Int |
| level | Whether the user was a free or paid member for that song play | Varchar |
| artist_id | ID of the song artist | Varchar |
| session_id | Session ID of the song play | Int |
| location | User's location when the song was played | Varchar |
| user_agent | User's browser User Agent string | Varchar |


### Users Table
#### Description
Dimension Table containing information about each User.

#### Columns
| Column Name | Description | Datatype |
| --- | --- | --- |
| user_id | Unique ID of the User | Int - Primary Key |
| first_name | First name of the User | Varchar |
| last_name | Last name of the User | Varchar |
| gender | Gender of the user | Varchar |

### Songs Table
#### Description
Dimension Table containing additional information about each song.

#### Columns
| Column Name | Description | Datatype |
| --- | --- | --- |
| song_id | Unique ID of the song | Varchar - Primary Key |
| title | Title of the song | Varchar |
| artist_id | ID of the artist | Varchar |
| year | year the song was released | int |
| duration | duration of the song in seconds | numeric |

### Artists Table
#### Description
Dimension Table containing additional information about each artist.

#### Columns
| Column Name | Description | Datatype |
| --- | --- | --- |
| artist_id | Unique ID of the artist | Varchar - Primary Key |
| name | Name of the artist | Varchar |
| location | Location of the artist | varchar |
| latitude | Location of the artist - latitude | float |
| longitude | Location of the artist - longitude | float |

### Time Table
#### Description
Dimension Table containing pre-converted date and time data.

#### Columns
| Column Name | Description | Datatype |
| --- | --- | --- |
| start_time | Time in Unix epoch time | Big Int - Primary Key |
| hour | Hour, in 24 hour clock | Int |
| day | Day of the month | Int |
| week | Week of year | Int |
| month | Month of the year | Int |
| year | Year | Int |
| weekday | Weekday | Varchar |

## Example Queries

### How many Free vs Paid users are playing songs?
```
select count(1)
    , level 
from songplays 
group by level;
```

### What is the Gender of users listening to the most songs?
```
select count(1)
    , u.gender
from songplays as s 
join users as u 
    on s.user_id = u.user_id 
group by s.user_id, u.gender 
order by count desc 
limit 10;
```

### Most popular day to play music?
```
select weekday,
    count(1) from 
songplays as s 
join time as t 
    on s.start_time = t.start_time 
group by weekday
```