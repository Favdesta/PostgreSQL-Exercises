SELECT *
FROM cd.facilities; 

SELECT name, membercost
FROM cd.facilities;  

SELECT *
FROM cd.facilities
WHERE membercost > 0;

SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities 
WHERE membercost > 0 and (membercost < monthlymaintenance/50.0);   

SELECT *
FROM cd.facilities 
WHERE name like '%Tennis%';         

SELECT *
FROM cd.facilities 
WHERE facid in (1,5); 

SELECT * 
FROM cd.facilities
WHERE
    facid in (
	    SELECT facid
            FROM cd.facilities
			);

SELECT name, 
	CASE
        WHEN
         (monthlymaintenance > 100) THEN 'expensive'
        ELSE
		    'cheap' END AS cost
	FROM cd.facilities;      


SELECT memid, surname, firstname, joindate 
FROM cd.members
WHERE joindate >= '2012-09-01';    

SELECT DISTINCT surname 
FROM cd.members
ORDER BY surname
LIMIT 10; 

SELECT surname 
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

SELECT max(joindate) as latest
FROM cd.members;


SELECT firstname, surname, joindate
FROM cd.members
WHERE joindate = (
	SELECT max(joindate) 
	FROM cd.members );     

SELECT firstname, surname, max(joindate)
FROM cd.members


SELECT firstname, surname, joindate
FROM cd.members
ORDER BY joindate desc
LIMIT 1;

