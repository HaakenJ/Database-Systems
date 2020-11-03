SELECT playerID, POS
FROM fielding
WHERE yearID >= '2009' AND POS = 'SS' AND G > 40
GROUP BY playerID;

SELECT
	p.playerID,
	nameFirst,
    nameLast,
    ss.POS,
    ss.yearID
FROM people p
	JOIN (
		select playerID, POS, yearID, G from fielding
		WHERE POS = 'SS' AND G > 40 AND yearID >= '2009'
    ) ss ON p.playerID = ss.playerID;

/* Get sum of homeruns for all players in last 10 years */
SELECT
	b.playerID,
    p.nameFirst,
    p.nameLast,
    HR,
    #SUM(b.HR),
    b.yearID
FROM people p 
	JOIN fielding f ON p.playerID = f.playerID
    JOIN batting b  ON p.playerID = b.playerID
WHERE b.yearID >= '2009' AND f.POS = 'SS'
ORDER BY b.playerID;
#GROUP BY b.playerID;

/* Get all players who have played at shortstop for more than 25% of a season */
SELECT
	p.playerId,
    nameFirst,
    nameLast,
    POS
FROM people p
	JOIN fielding f ON p.playerID = f.playerID
WHERE
	POS = 'SS' AND f.G > 40;

SELECT 
	p.playerID,
	nameFirst, 
	nameLast,
	POS,
	SUM(b.HR),
	b.yearId
FROM people p
	JOIN batting b  ON p.playerID = b.playerID
	JOIN fielding f ON p.playerID = f.playerID
WHERE 
	POS = 'SS'        AND 
	b.yearID >= '2009' AND
	f.G > 40               # Only players who played as SS for more than 25% of games in 2019
GROUP BY p.playerID;

  select playerID, POS, sum(G) as sm
  from Fielding 
  where POS = 'SS' AND yearID = '2019'
  group by playerID, POS;

/* Gets slugging and info for only shortstops */
SELECT 
	p.playerID,
	nameFirst, 
	nameLast,
	POS,
	AB, 
	b.yearId, 
	((H - 2B - 3B - HR) + (2B * 2) + (3B * 3) + (HR * 4)) / AB AS Slugging # Calculate slugging pct
FROM people p
JOIN batting b  ON p.playerID = b.playerID
JOIN fielding f ON p.playerID = f.playerID
WHERE 
	POS = 'SS'        AND 
    b.yearID = '2019' AND
    f.G > 40               # Only players who played as SS for more than 25% of games in 2019
GROUP BY p.playerID;
    
/* Gets slugging percentage and player names for all players */    
SELECT 
	nameFirst, 
	nameLast,
	AB, 
	yearId, 
	((H - 2B - 3B - HR) + (2B * 2) + (3B * 3) + (HR * 4)) / AB AS Slugging # Calculate slugging pct
FROM people p
JOIN batting b  ON p.playerID = b.playerID;
/* Get player id's of all shortstops */
SELECT 
	p.playerID,
    POS
FROM people p
	JOIN fielding f ON p.playerID = f.playerID
WHERE
	POS = 'SS' AND
    G   > 40;
    
/* Display top 20 shortstops by slugging percentage */
SELECT
	nameFirst AS 'First Name', 
    nameLast  AS 'Last Name', 
    Slugging
FROM (
	SELECT 
		p.playerID,
		nameFirst, 
		nameLast,
		POS,
		AB, 
		b.yearId, 
		((H - 2B - 3B - HR) + (2B * 2) + (3B * 3) + (HR * 4)) / AB AS Slugging # Calculate slugging pct
	FROM people p
	JOIN batting b  ON p.playerID = b.playerID
	JOIN fielding f ON p.playerID = f.playerID
	WHERE 
		POS = 'SS'        AND  # Only players who played as shortstop
		b.yearID = '2019' AND  # Only data from 2019
		f.G > 120              # Only players who played as SS for more than 75% of games in 2019
	GROUP BY p.playerID
) t1
WHERE
	AB       > 300  AND # Players with at least 300 at bats
    Slugging > .400 # Slugging pct over .400
ORDER BY Slugging DESC
LIMIT 20;

/* Display home run leading shortstops for last 10 years */
SELECT
	p.playerID,
	p.nameFirst        AS 'First Name',
    p.nameLast         AS 'Last Name',
    SUM(b.HR)          AS 'Home Runs',
    ROUND(AVG(b.HR))   AS 'Average HR'
FROM people p
	JOIN batting b  ON p.playerID = b.playerID
    JOIN (
		# Get table of shortstops in past 10 years
		SELECT playerID, POS
		FROM fielding
		WHERE 
			yearID >= '2009' AND # only last 10 years
            POS     = 'SS'   AND # only shortstops
			G       > 120        # only players who played 75% of the season as shortstop
		GROUP BY playerID
    ) f ON p.playerID = f.playerID
WHERE 
	b.yearID >= 2009
GROUP BY playerID
ORDER BY SUM(b.HR) DESC
LIMIT 20;

/* Display home run leading shortstops over the past 10 years that are under 30 */
SELECT
	p.playerID,
	p.nameFirst                          AS 'First Name',
    p.nameLast                           AS 'Last Name',
    YEAR(CURDATE()) - p.birthYear        AS Age,
    SUM(b.HR)                            AS 'Total HR',
    ROUND(AVG(b.HR))                     AS 'Avg HR'
FROM people p
	JOIN batting b ON p.playerID = b.playerID
    JOIN (
		# Get table of shortstops in past 10 years
		SELECT playerID, POS
		FROM fielding
		WHERE 
			yearID >= '2009' AND # only last 10 years
            POS     = 'SS'   AND # only shortstops
			G       > 120        # only players who played 75% of the season as shortstop
		GROUP BY playerID
    ) f ON p.playerID = f.playerID
WHERE 
	b.yearID >= 2009 AND                   # Show results for past 10 years
    (YEAR(CURDATE()) - p.birthYear) < 30   # Only players under 30
GROUP BY playerID
ORDER BY SUM(b.HR) DESC
LIMIT 20;


/* 
 * Stored procedure to get home run leading players since a 
 * given year who are currently under a specified age
 *
 * @param maxAge    INT     the maximum age player to search for
 * @param sinceYear INT     the beginning year you want data for
 * @param position  CHAR(2) the position player you want to search for
 */
DELIMITER //
CREATE PROCEDURE filterPlayers(
	IN maxAge    INT,
    IN sinceYear INT,
    IN position  CHAR(2)
    
)
BEGIN
SELECT
	p.playerID,
	p.nameFirst                          AS 'First Name',
    p.nameLast                           AS 'Last Name',
    YEAR(CURDATE()) - p.birthYear        AS Age,
    SUM(b.HR)                            AS 'Total HR',
    ROUND(AVG(b.HR))                     AS 'Avg HR'
FROM people p
	JOIN batting b ON p.playerID = b.playerID
    JOIN (
		# Get table of shortstops in past 10 years
		SELECT playerID, POS
		FROM fielding
		WHERE 
			yearID >= sinceYear AND # only since sinceYear
            POS     = position  AND # only players who played postion
			G       > 120           # only players who played 75% of the season as shortstop
		GROUP BY playerID
    ) f ON p.playerID = f.playerID
WHERE 
	b.yearID >= sinceYear AND                # show results since sinceYear
    (YEAR(CURDATE()) - p.birthYear) < maxAge # only players under the max age
GROUP BY playerID
ORDER BY SUM(b.HR) DESC
LIMIT 20;

END //
DELIMITER ;

CALL filterPlayers(28, 2018, '1B');