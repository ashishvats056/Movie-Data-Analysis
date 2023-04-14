create database movies
use movies

create table movie(id varchar(50), name varchar(500));
create table shows(movie_id varchar(50), showdatetime DATETIME, screen_id varchar(50), cinema_hall_id varchar(50));
create table cinema_halls(id varchar(50), name varchar(500), address varchar(1000));
create table screens(id varchar(50), name varchar(500), cinema_hall_id varchar(50), type varchar(10), price int);

INSERT INTO movie values('MOV1', 'Baadshaah');
INSERT INTO movie values('MOV2', 'Titanic');
INSERT INTO movie values('MOV3', 'Masaan');

INSERT INTO shows values('MOV1','2022-01-05 12:00','SCR1','CIN1');
INSERT INTO shows values('MOV1','2022-01-05 17:00','SCR2','CIN1');
INSERT INTO shows values('MOV1','2022-01-06 23:00','SCR2','CIN1');
INSERT INTO shows values('MOV1','2022-01-06 09:00','SCR1','CIN1');
INSERT INTO shows values('MOV1','2022-01-07 13:00','SCR1','CIN2');
INSERT INTO shows values('MOV1','2022-01-06 13:00','SCR2','CIN2');
INSERT INTO shows values('MOV2','2022-01-16 13:00','SCR1','CIN1');
INSERT INTO shows values('MOV2','2022-01-17 19:00','SCR2','CIN1');
INSERT INTO shows values('MOV2','2022-01-17 19:00','SCR1','CIN2');
INSERT INTO shows values('MOV3','2022-05-16 13:00','SCR1','CIN1');
INSERT INTO shows values('MOV3','2022-05-16 13:00','SCR2','CIN2');
INSERT INTO shows values('MOV3','2022-04-28 13:00','SCR2','CIN2');

INSERT INTO cinema_halls values('CIN1','PVR Cinemas','Bangalore, Karnataka');
INSERT INTO cinema_halls values('CIN2','AMB Cinemas','Hyderabad, Telangana');
INSERT INTO cinema_halls values('CIN3','Error','Earth');

INSERT into screens values('SCR1','AUDI-01', 'CIN1', '2D', 120);
INSERT into screens values('SCR2','AUDI-02', 'CIN1', '3D', 240);
INSERT into screens values('SCR1','Theater-01', 'CIN2', '3D', 260);
INSERT into screens values('SCR2','Theater-02', 'CIN2', '4DX', 460);

-- find release date of each movie
select movie.id, movie.name, release.release_date
from movie
inner join
(select movie_id, 
datefromparts(year(min(showdatetime)), month(min(showdatetime)), day(min(showdatetime))) as release_date
from shows
group by movie_id) release
on movie.id = release.movie_id

-- find duration off each movie in the cinemas
select movie.id, movie.name, movietime.movie_dates_duration
from movie
inner join
(select movie_id, 
datediff(day, datefromparts(year(min(showdatetime)), month(min(showdatetime)), day(min(showdatetime))),
datefromparts(year(max(showdatetime)), month(max(showdatetime)), day(max(showdatetime))))+1 as movie_dates_duration
from shows
group by movie_id) movietime
on movie.id = movietime.movie_id

-- find total earning of each movie
select movie.id, movie.name, collect.total_collection
from movie
inner join
(select show.movie_id, sum(screen.price) as total_collection
from
(select movie_id, cinema_hall_id, screen_id
from shows) show
inner join
(select id, cinema_hall_id, price
from screens) screen
on show.screen_id=screen.id and show.cinema_hall_id = screen.cinema_hall_id
group by show.movie_id) collect
on movie.id = collect.movie_id

select * from movie
select * from shows
select * from cinema_halls
select * from screens

-- Delete cinema halls without any screen registered in the database
delete from cinema_halls
where cinema_halls.id in
(select c.id
from cinema_halls c
left outer join
screens s
on c.id = s.cinema_hall_id
where s.id is null)

-- get earning of movies per cinema halls
select c.movie_id, movie.name, c.cinema_hall_id, c.name, c.address, c.collection  from
(select * from
(select shows.movie_id, shows.cinema_hall_id, sum(screens.price) as collection from shows
inner join screens
on shows.cinema_hall_id=screens.cinema_hall_id and shows.screen_id=screens.id
group by shows.cinema_hall_id, shows.movie_id) x
inner join cinema_halls
on x.cinema_hall_id=cinema_halls.id) c
inner join movie
on c.movie_id=movie.id
order by movie_id


