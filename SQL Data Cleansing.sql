select * from dbo.movies1

-- Updating Column names of table to make them consistent
sp_rename 'dbo.movies1.MOVIES', 'Movies','COLUMN'
sp_rename 'dbo.movies1.YEAR', 'Year','COLUMN'
sp_rename 'dbo.movies1.GENRE', 'Genre','COLUMN'
sp_rename 'dbo.movies1.RATING', 'Rating','COLUMN'
sp_rename 'dbo.movies1.ONE_LINE', 'Summary','COLUMN'
sp_rename 'dbo.movies1.STARS', 'DirectorStars','COLUMN'
sp_rename 'dbo.movies1.VOTES', 'Votes','COLUMN'
sp_rename 'dbo.movies1.RunTime', 'Runtime','COLUMN'

-- Getting rid of the NULL values and making them blanks
update dbo.movies1
set Gross = ''
where Gross is null 

update dbo.movies1
set Runtime = ''
where Runtime is null 


update dbo.movies1
set Year = ''
where Year is null

update dbo.movies1
set Genre = ''
where Genre is null

update dbo.movies
set Summary = ''
where Summary is null

update dbo.movies1
set Rating = ''
where rating is null 

update dbo.movies1
set Votes = ''
where Votes is null 

--Rounding Rating column to one decimal place
update dbo.movies1
set Rating = ROUND(Rating, 1)


-- Add another column called Director and Stars and split them into two columns from the original one. After, drop original combined column 
Alter table dbo.movies1
add Director varchar(max)

alter table dbo.movies1
add Stars varchar(max)


select * from dbo.movies1

UPDATE dbo.movies1
SET Director = CASE 
                WHEN CHARINDEX('|', DirectorStars) > 0 
                THEN SUBSTRING(DirectorStars, 1, CHARINDEX('|', DirectorStars) - 1)
                ELSE NULL
              END,
    Stars = CASE 
                WHEN CHARINDEX('|', DirectorStars) > 0 
                THEN SUBSTRING(DirectorStars, CHARINDEX('|', DirectorStars) + 1, LEN(DirectorStars) - CHARINDEX('|', DirectorStars))
                ELSE DirectorStars
              END;

update dbo.movies1
set Director = ''
where Director is null

alter table dbo.movies1
drop column DirectorStars

--Changing the summary column 'add a plot' to 'NA'
update dbo.movies1
set Summary = 'NA'
where Summary Like '%Add a Plot%'

select * from dbo.movies1
where summary = 'NA'


Select * from dbo.movies1

--Removing the Prefix Director and Stars from the two columns 
update dbo.movies1
Set Director = replace(Director, 'Director:','')
where Director like '%Director:%'

update dbo.movies1
Set Director = replace(Director, 'Directors:','')
where Director like '%Directors:%'

update dbo.movies1
Set Stars = replace(Stars, 'Stars:','')
where Stars like '%Stars:%'

update dbo.movies1
Set Stars = replace(Stars, 'Star:','')
where Stars like '%Star:%'

--Trimminmg the Director and Stars columns
Update dbo.movies1
set Director = TRIM(Director)

Update dbo.movies1
set Stars = TRIM(Stars)