# PostgreSQL-Exercises

Schema Reminder 
![Screenshot 2025-01-14 201556](https://github.com/user-attachments/assets/5297ed44-38da-4824-8cb3-27da6012e0cb)

# Retrieve everything from a table
Q: How can you retrieve all the information from the cd.facilities table?
``` sql
SELECT
    *
FROM
    cd.facilities; 
```
The SELECT statement is the basic starting block for queries that read information out of the database. A minimal select statement is generally comprised of select [some set of columns] from [some table or group of tables].

In this case, we want all of the information from the facilities table. The from section is easy - we just need to specify the cd.facilities table. 'cd' is the table's schema - a term used for a logical grouping of related information in the database.

Next, we need to specify that we want all the columns. Conveniently, there's a shorthand for 'all columns' - *. We can use this instead of laboriously specifying all the column names.

#Retrieve specific columns from a table
Q: You want to print out a list of all of the facilities and their cost to members. How would you retrieve a list of only facility names and costs?

``` sql
SELECT
    name, membercost
FROM
    cd.facilities;  
```
For this question, we need to specify the columns that we want. We can do that with a simple comma-delimited list of column names specified to the select statement. All the database does is look at the columns available in the FROM clause, and return the ones we asked for, as illustrated below

![Screenshot 2025-01-14 223449](https://github.com/user-attachments/assets/2c0fbe10-a99f-452a-b934-e2392c385d6d)

Generally speaking, for non-throwaway queries it's considered desirable to specify the names of the columns you want in your queries rather than using *. This is because your application might not be able to cope if more columns get added into the table.

# Control which rows are retrieved 
Q: How can you produce a list of facilities that charge a fee to members?
``` sql
SELECT *
FROM
    cd.facilities
WHERE
    membercost > 0;
```
The FROM clause is used to build up a set of candidate rows to read results from. In our examples so far, this set of rows has simply been the contents of a table. In future we will explore joining, which allows us to create much more interesting candidates.

Once we've built up our set of candidate rows, the WHERE clause allows us to filter for the rows we're interested in - in this case, those with a membercost of more than zero. As you will see in later exercises, WHERE clauses can have multiple components combined with boolean logic - it's possible to, for instance, search for facilities with a cost greater than 0 and less than 10. The filtering action of the WHERE clause on the facilities table is illustrated below:

![Screenshot 2025-01-14 223718](https://github.com/user-attachments/assets/f3f47ab0-c6cb-454f-8a75-5cd339986723)

# Control which rows are retrieved - part 2
Q: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.

``` sql
SELECT
    facid, name, membercost, monthlymaintenance
FROM
    cd.facilities 
WHERE 
		membercost > 0 and 
		(membercost < monthlymaintenance/50.0);   
```
The WHERE clause allows us to filter for the rows we're interested in - in this case, those with a membercost of more than zero, and less than 1/50th of the monthly maintenance cost. As you can see, the massage rooms are very expensive to run thanks to staffing costs!

When we want to test for two or more conditions, we use AND to combine them. We can, as you might expect, use OR to test whether either of a pair of conditions is true.

You might have noticed that this is our first query that combines a WHERE clause with selecting specific columns. You can see in the image below the effect of this: the intersection of the selected columns and the selected rows gives us the data to return. This may not seem too interesting now, but as we add in more complex operations like joins later, you'll see the simple elegance of this behaviour.

![Screenshot 2025-01-14 223916](https://github.com/user-attachments/assets/320c7c4e-bcc3-44a3-a611-a1b5f97a0e1e)

# Basic string searches
Q: How can you produce a list of all facilities with the word 'Tennis' in their name?
```sql
SELECT
    *
FROM
    cd.facilities 
WHERE
    name like '%Tennis%';         
```
SQL's LIKE operator provides simple pattern matching on strings. It's pretty much universally implemented, and is nice and simple to use - it just takes a string with the % character matching any string, and _ matching any single character. In this case, we're looking for names containing the word 'Tennis', so putting a % on either side fits the bill.

There's other ways to accomplish this task: Postgres supports regular expressions with the ~ operator, for example. Use whatever makes you feel comfortable, but do be aware that the LIKE operator is much more portable between systems.

# Matching aganist multiple possibe values 
Q: How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
``` sql
SELECT
    *
FROM
    cd.facilities 
WHERE
    facid in (1,5); 
```
The obvious answer to this question is to use a WHERE clause that looks like where facid = 1 or facid = 5. An alternative that is easier with large numbers of possible matches is the IN operator. The IN operator takes a list of possible values, and matches them against (in this case) the facid. If one of the values matches, the where clause is true for that row, and the row is returned.

The IN operator is a good early demonstrator of the elegance of the relational model. The argument it takes is not just a list of values - it's actually a table with a single column. Since queries also return tables, if you create a query that returns a single column, you can feed those results into an IN operator. To give a toy example:

``` sql
SELECT
    * 
FROM
    cd.facilities
WHERE
    facid in (
			SELECT
                facid
            FROM
                cd.facilities
			);
```
This example is functionally equivalent to just selecting all the facilities, but shows you how to feed the results of one query into another. The inner query is called a subquery.

# Classify results into buckets
Q:How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities in question.

``` sql
SELECT name, 
	CASE
        WHEN
         (monthlymaintenance > 100) THEN 'expensive'
        ELSE
		    'cheap' END AS cost
	FROM cd.facilities;      
```
This exercise contains a few new concepts. The first is the fact that we're doing computation in the area of the query between SELECT and FROM. Previously we've only used this to select columns that we want to return, but you can put anything in here that will produce a single result per returned row - including subqueries.

The second new concept is the CASE statement itself. CASE is effectively like if/switch statements in other languages, with a form as shown in the query. To add a 'middling' option, we would simply insert another when...then section.

Finally, there's the AS operator. This is simply used to label columns or expressions, to make them display more nicely or to make them easier to reference when used as part of a subquery.

# Working with dates
Q: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.

``` sql
SELECT
    memid, surname, firstname, joindate 
FROM
    cd.members
WHERE
    joindate >= '2012-09-01';    
```
This is our first look at SQL timestamps. They're formatted in descending order of magnitude: YYYY-MM-DD HH:MM:SS.nnnnnn. We can compare them just like we might a unix timestamp, although getting the differences between dates is a little more involved (and powerful!). In this case, we've just specified the date portion of the timestamp. This gets automatically cast by postgres into the full timestamp 2012-09-01 00:00:00.

# Removing duplicates, and ordering results
Q: How can you produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.

``` sql
SELECT DISTINCT
    surname 
FROM
    cd.members
ORDER BY
    surname
LIMIT 10; 
```

There's three new concepts here, but they're all pretty simple.

    - Specifying DISTINCT after SELECT removes duplicate rows from the result set. Note that this applies to rows: if row A has multiple columns, row B is only equal to it if the values in all columns are the same. As a general rule, don't use DISTINCT in a willy-nilly fashion - it's not free to remove duplicates from large query result sets, so do it as-needed.
    - Specifying ORDER BY (after the FROM and WHERE clauses, near the end of the query) allows results to be ordered by a column or set of columns (comma separated).
    - The LIMIT keyword allows you to limit the number of results retrieved. This is useful for getting results a page at a time, and can be combined with the OFFSET keyword to get following pages. This is the same approach used by MySQL and is very convenient - you may, unfortunately, find that this process is a little more complicated in other DBs.

# Combining results from multiple queries
Q: You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!

``` sql
SELECT
    surname 
FROM
    cd.members
UNION
SELECT
    name
FROM
    cd.facilities;
```
The UNION operator does what you might expect: combines the results of two SQL queries into a single table. The caveat is that both results from the two queries must have the same number of columns and compatible data types.

UNION removes duplicate rows, while UNION ALL does not. Use UNION ALL by default, unless you care about duplicate results.

# Simple aggregation
Q: You'd like to get the signup date of your last member. How can you retrieve this information?

``` sql
SELECT
    max(joindate) as latest
FROM
    cd.members;
```
This is our first foray into SQL's aggregate functions. They're used to extract information about whole groups of rows, and allow us to easily ask questions like:

    - What's the most expensive facility to maintain on a monthly basis?
    - Who has recommended the most new members?
    - How much time has each member spent at our facilities?
The MAX aggregate function here is very simple: it receives all the possible values for joindate, and outputs the one that's biggest. There's a lot more power to aggregate functions, which you will come across in future exercises.

# More aggregation
Q: You'd like to get the first and last name of the last member(s) who signed up - not just the date. How can you do that?

```sql
SELECT
    firstname, surname, joindate
FROM
    cd.members
WHERE
    joindate = 
		(SELECT
            max(joindate) 
			FROM
                cd.members);     
```

In the suggested approach above, you use a subquery to find out what the most recent joindate is. This subquery returns a scalar table - that is, a table with a single column and a single row. Since we have just a single value, we can substitute the subquery anywhere we might put a single constant value. In this case, we use it to complete the WHERE clause of a query to find a given member.

You might hope that you'd be able to do something like below:

```sql
SELECT
    firstname, surname, max(joindate)
FROM
    cd.members
```
Unfortunately, this doesn't work. The MAX function doesn't restrict rows like the WHERE clause does - it simply takes in a bunch of values and returns the biggest one. The database is then left wondering how to pair up a long list of names with the single join date that's come out of the max function, and fails. Instead, you're left having to say 'find me the row(s) which have a join date that's the same as the maximum join date'.

As mentioned by the hint, there's other ways to get this job done - one example is below. In this approach, rather than explicitly finding out what the last joined date is, we simply order our members table in descending order of join date, and pick off the first one. Note that this approach does not cover the extremely unlikely eventuality of two people joining at the exact same time :-).

``` sql
select firstname, surname, joindate
	from cd.members
order by joindate desc
limit 1;
```
