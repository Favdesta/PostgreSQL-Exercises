# Simple SQL Queries

Schema Reminder 
![Screenshot 2025-01-14 201556](https://github.com/user-attachments/assets/5297ed44-38da-4824-8cb3-27da6012e0cb)

You can find the code here: [queries.sql](queries.sql) file

# Retrieve everything from a table
Q: How can you retrieve all the information from the cd.facilities table?
``` sql
SELECT
    *
FROM
    cd.facilities; 
```
The SELECT statement forms the foundation for retrieving data from databases. At its most basic, you build a query by specifying which columns you want (after the SELECT keyword) and which table(s) to get them from (after FROM).

In our example, we're pulling data from the facilities table in the cd schema. A schema helps organize related database objects together - think of it like a folder system.

To get every column from the table, we can use the * wildcard symbol instead of typing out each column name individually. This * is a handy shortcut that tells the database "give me everything."

# Retrieve specific columns from a table
Q: You want to print out a list of all of the facilities and their cost to members. How would you retrieve a list of only facility names and costs?

``` sql
SELECT
    name, membercost
FROM
    cd.facilities;  
```
For this question, when you want specific information rather than everything in a table, you can list out exactly which columns you want after the SELECT keyword, separating each column name with a comma. The database then checks what columns are available in the table(s) mentioned in your FROM clause and returns just the ones you asked for, as illustrated below

![Screenshot 2025-01-14 223449](https://github.com/user-attachments/assets/2c0fbe10-a99f-452a-b934-e2392c385d6d)

While using * is convenient, it's usually better practice to explicitly name your columns when writing queries you'll keep and reuse. This makes your queries more reliable - if someone adds new columns to the table later, your query will still return exactly what you expected rather than suddenly including extra columns that might cause problems in your application.

# Control which rows are retrieved 
Q: How can you produce a list of facilities that charge a fee to members?
``` sql
SELECT *
FROM
    cd.facilities
WHERE
    membercost > 0;
```
The FROM clause sets up your initial dataset - it defines which rows you'll be working with. So far, we've just pulled rows directly from single tables, but later we'll see how to combine data from multiple tables using joins to create more complex datasets.

After you have your base set of rows, you can use the WHERE clause as a filter to narrow down to just the rows you care about. In this example, we're filtering to only show rows where membercost is greater than zero. WHERE clauses can get quite sophisticated - you can combine multiple conditions using AND, OR, and other logical operators to create precise filters. For instance, you could find all facilities with costs between 0 and 10.

Think of it like this: FROM creates your starting pool of data, then WHERE acts like a sieve to keep only the rows that match your conditions, illustration below:

![Screenshot 2025-01-14 223718](https://github.com/user-attachments/assets/f3f47ab0-c6cb-454f-8a75-5cd339986723)

# Control which rows are retrieved - part 2
Q: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.

``` sql
SELECT
    facid, name, membercost, monthlymaintenance
FROM
    cd.facilities 
WHERE 
		membercost > 0 and (membercost < monthlymaintenance/50.0);   
```
The WHERE clause lets you filter your data based on specific conditions - here, we're looking for records where the membercost exceeds zero but is less than 2% (1/50th) of the monthly maintenance cost. This highlights how expensive the massage rooms are to maintain, mainly due to staff costs!

When you need multiple conditions in your filter, you can connect them with AND to require that both conditions must be true. Alternatively, using OR means at least one of the conditions must be true.

This query shows how WHERE and column selection work together: first, you pick your columns (SELECT), then filter the rows (WHERE). The final result is like a grid showing only the intersection of your chosen columns and the rows that passed your filter conditions. While this might seem straightforward now, this clean approach becomes particularly elegant when we start working with more complex operations like joins.

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
		(
	SELECT
            max(joindate) 
	FROM
	    cd.members
			);     
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
SELECT
   firstname, surname, joindate
FROM
   cd.members
ORDER BY
   joindate desc
LIMIT 1;
```
