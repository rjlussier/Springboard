/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT `name` AS facilities_w_fee -- return names of facilities only
		FROM `Facilities`		  -- search Facilities database
	WHERE `membercost` != 0       -- filter where membercost is not zero

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(`name`) AS no_fee_count -- use count aggregation to count instances meeting filter, return count
		FROM `Facilities`   -- search Facilites database
	WHERE `membercost` = 0  -- filter wehre membercost is zero

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT `facid`, `name`, `membercost`, `monthlymaintenance` -- return facid, name, membercost, and monthlymaintenance columns
		FROM `Facilities` -- search Facilities database
	WHERE membercost < .2 * monthlymaintenance -- filter where membercost is less than 20% of monthlymaintenance

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *  -- return all columns
		FROM `Facilities` -- search Facilities database
	WHERE facid IN (1, 5) -- filter out elements where facid is in the list 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT `name`, `monthlymaintenance`, -- return name and monthlymaintenance columns
		CASE WHEN monthlymaintenance > 100 THEN 'expensive' -- create new column 'value' labeling rows as expensive or cheap
		ELSE 'cheap' END AS `value`
	FROM `Facilities` -- search Facilities database

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT CONCAT(firstname, ' ', surname) AS newest_member -- return new column concatenating first and last name as one element
		FROM Members -- search Members database
	WHERE joindate = (SELECT max(joindate) FROM Members) -- filter where sign up date is equal to the maximum joindates

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(Members.firstname, ' ', Members.surname) AS full_name, -- return unique entries for full name...
	   Facilities.name AS court_name -- ...and return name of tennis court
	FROM Bookings -- search Bookings database
	JOIN Members		
  		ON Bookings.memid = Members.memid -- inner join Members database where memid matches
	JOIN Facilities
  		ON Bookings.facid = Facilities.facid	-- inner join Facilities database where facid matches
 WHERE Bookings.facid IN (0, 1) -- filter where facid is either 0 or 1
 ORDER BY full_name -- sort alphabetically by full name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name, -- return facility name
	   CONCAT(Members.firstname, ' ', Members.surname) AS full_name, -- return full name
 	   CASE WHEN Bookings.memid = 0 THEN Bookings.slots*Facilities.guestcost 
 	   ELSE Bookings.slots*Facilities.membercost END AS booking_cost -- return different cost based on based on whether or not the user is a guest or member
	FROM Bookings -- search Bookings database
	JOIN Facilities
		ON Bookings.facid = Facilities.facid -- inner join Facilities to access facility name
	JOIN Members
		ON Bookings.memid = Members.memid -- inner join Members to access member name
  WHERE starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' -- filter bookings from the day 2012-09-14
  AND CASE WHEN Bookings.memid = 0 THEN Bookings.slots*Facilities.guestcost 
	  ELSE Bookings.slots*Facilities.membercost END > 30 -- also filter the cost value is greater than 30 dollars
  ORDER BY 3 DESC -- sort in descending order based on the cost

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT * -- return all values from subquery, subquery allows reference to booking_cost alias later
  FROM(
		SELECT Facilities.name,  -- return facility name
 		CONCAT(Members.firstname, ' ', Members.surname) AS full_name, -- return members full name
 		CASE WHEN Bookings.memid = 0 THEN Bookings.slots*Facilities.guestcost  
 		ELSE Bookings.slots*Facilities.membercost END AS booking_cost -- return cost based on if user is member or guest
  		  FROM Bookings 
  			JOIN Facilities
			  ON Bookings.facid = Facilities.facid -- inner join Facilities where facid matches to access facility name
 			JOIN Members
	          ON Bookings.memid = Members.memid	-- inner join Members where memid matches to access member names
 	 WHERE Bookings.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'  -- filter where date is 2012-09-14
  ) sub  -- assign subquery alias
  WHERE sub.booking_cost > 30 -- filter bookings that cost more than 30 dollars
  ORDER BY 3 DESC -- sort by booking cost in descending order

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT sub.facility_name, -- return facility name
	   SUM(sub.slots*sub.cost) AS revenue -- add up all bookings to get total revenue
	FROM(
		SELECT f.name AS facility_name, -- subquery to get facility name, member id, booking length, and member/guest unit cost
	  		   b.memid,
	  		   b.slots,
	  		   CASE WHEN b.memid = 0 THEN f.guestcost ELSE f.membercost END AS cost
  		  FROM Bookings b
		  JOIN Facilities f -- inner join facilities database to access facility name where facids match
			ON b.facid = f.facid
	) sub
  GROUP BY 1 -- group by facility name
  HAVING revenue < 1000 -- filter where revenue is less than 1000 dollars
  ORDER BY 2 DESC -- sort in descending order by revenue
