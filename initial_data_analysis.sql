/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * 
from [members$]


--create new columns brekaing out registration time
drop view member_registration
create view member_registration as

select msno,
registration_init_time,
 expiration_date,
left(cast(registration_init_time as decimal(8,0)),4) as reg_year,
left(right(cast(registration_init_time as decimal(8,0)),4),2) as reg_month,
right(cast(registration_init_time as decimal(8,0)),2) as reg_date,
datediff(dd,cast(cast(cast(registration_init_time as INT)as varchar(8)) as DATE),cast(cast(cast(expiration_date as INT)as varchar(8)) as DATE)) date_diff
from members$

select distinct(reg_year) from member_registration
order by reg_year
where reg_month = 12
and length_as_member > 10

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
      --,[song_id]
      --,[source_system_tab]
      --,[source_screen_name]
      --,[source_type]
count(*) 
  FROM [train$]


  where msno in (select msno from member_registration
					where reg_month =12
					and reg_date = 31
					and length_as_member > 10
					)
  and target = 0

  -- year  # repeats   ## skips
--  2004    7429		3559
--2005  12885			5710
--2006    19473			8526
--2007   22815			9912
--2008   15281			8075
--2009   15204			7018
--2010   35171			17133
--2011   94692			43844
--2012  60465			26438	
--2013   93882			40265
--2014  85539			35020
--2015  126292			51852
--2016  128522			59099
--2017



-- month  # repeats   ## skips
-- 01   69496			31471
-- 2    56982			25265
-- 3    55727			23626
-- 04   39008			18392
-- 05   42057			17821
-- 06   57718			24289
-- 07   49511			20567
-- 08  67737			29478
-- 09  60144			25978
-- 10  71406			30612
-- 11  76835			36234
-- 12  71029			32718


-- what users listened to the most songs?

select top 50 * from members$

SELECT top 100 t.msno,
      --,[song_id]
      --,[source_system_tab]
      --,[source_screen_name]
      --,[source_type]
			count(*) total_listens,
			m.registration_init_time,
			m.reg_month,
			m.reg_date,
			mem.city,
			mem.bd,
			mem.gender,
			mem.registered_via,
			m.length_as_member
  FROM [train$] t
  inner join member_registration m
  on m.msno = t.msno 
  inner join members$ mem
  on mem.msno = m.msno
    where t.target  =1
	and mem.registered_via = 9
  group by t.msno,m.registration_init_time,m.reg_month,m.reg_date,mem.city,mem.bd,mem.gender,mem.registered_via,m.length_as_member
  order by count(*) desc


  -- show user by total listens and total skips

  select top 500
  t.msno, 
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
  m.registered_via
  from train$ t
  inner join members$ m
  on m.msno = t.msno

  --where msno = '4+Vm4UTMchhw0yQGjkMRmYZ3RVVML36DvdxRxujA5PE='
  group by t.msno,m.registered_via
    order by total_skips desc



	--- see if there is a pattern as to when users "expire"

		  select top 10
  t.msno, 
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
    sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end)) total_listens, 
  convert(decimal(10,3),cast((sum((case when target = 1 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_replay,
  convert(decimal(10,3),cast((sum((case when target = 0 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_skip,
  m.registration_init_time
 , m.expiration_date
 ,mem.date_diff
  from train$ t
  inner join members$ m
  on m.msno = t.msno
  inner join member_registration mem
  on mem.msno = m.msno
group by t.msno,m.expiration_date,m.registration_init_time,mem.reg_month,mem.date_diff
    order by total_replays desc


		  select top 10
  t.msno, 
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
    sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end)) total_listens, 
  convert(decimal(10,3),cast((sum((case when target = 1 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_replay,
  convert(decimal(10,3),cast((sum((case when target = 0 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_skip,
  m.registration_init_time
 , m.expiration_date
 ,mem.date_diff
  from train$ t
  inner join members$ m
  on m.msno = t.msno
  inner join member_registration mem
  on mem.msno = m.msno
group by t.msno,m.expiration_date,m.registration_init_time,mem.reg_month,mem.date_diff
    order by total_skips desc


	create view test_time_diff as

select 
cast(cast(cast(registration_init_time as INT)as varchar(8)) as DATE) registration_init_time,
cast(cast(cast(expiration_date as INT)as varchar(8)) as DATE) expiration_date

--datediff(dd,registration_init_time,expiration_date)
 from members$

select top 5 
registration_init_time,
expiration_date,
datediff(dd,registration_init_time,expiration_date) diff_in_days
 from test_time_diff

 drop view member_registration

create view member_registration as

select 
t.msno,
m.bd,
m.city,
m.registration_init_time,
m.expiration_date,
datediff(dd,cast(cast(cast(m.registration_init_time as INT)as varchar(8)) as DATE),cast(cast(cast(m.expiration_date as INT)as varchar(8)) as DATE)) date_diff,
m.gender,
left(cast(m.registration_init_time as decimal(8,0)),4) as reg_year,
left(right(cast(m.registration_init_time as decimal(8,0)),4),2) as reg_month,
right(cast(m.registration_init_time as decimal(8,0)),2) as reg_date,
left(cast(m.expiration_date as decimal(8,0)),4) as exp_year,
left(right(cast(m.expiration_date as decimal(8,0)),4),2) as exp_month,
right(cast(m.expiration_date as decimal(8,0)),2) as exp_date,
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
  sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end)) total_listens, 
  convert(decimal(10,3),cast((sum((case when target = 1 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_replay,
  convert(decimal(10,3),cast((sum((case when target = 0 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_skip
 from train$ t 
 inner join members$ m
 on m.msno = t.msno
 group by t.msno,
		 m.bd,
		m.city,
		m.expiration_date,
		m.gender,
		m.registration_init_time


----- use training data to look at most repeated songs/what song shows up most in the data set


select top 10 * from songs$

select 
t.song_id,
s.genre_id_1,
s.genre_id_2,
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
  sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end)) total_listens,
  round(s.song_length_ms/1000 * 0.0166667,2)
 from train$ t
 inner join songs$ s
 on s.song_id = t.song_id
 group by t.song_id,s.song_length_ms,s.genre_id_1,s.genre_id_2
 order by total_skips desc

 -- total replays/skips based on the source screen name and the source type

  select  --*  from train$
 source_screen_name, 
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
   convert(decimal(10,3),cast((sum((case when target = 1 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_replay,
  convert(decimal(10,3),cast((sum((case when target = 0 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_skip
 from train$
 group by source_screen_name
 order by percentage_replay desc


  select  --*  from train$
 source_type, 
  sum((case when target = 1 then 1 else 0 end)) total_replays,
  sum((case when target = 0 then 1 else 0 end)) total_skips,
   convert(decimal(10,3),cast((sum((case when target = 1 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_replay,
  convert(decimal(10,3),cast((sum((case when target = 0 then 1 else 0 end))) as float)/cast((sum((case when target = 1 then 1 else 0 end)) + sum((case when target = 0 then 1 else 0 end))) as float)) percentage_skip
 from train$
 group by source_type
 order by percentage_replay desc



