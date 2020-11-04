-- Normal Join  Query #1  (MY PREFERENCE)
select a.actor_id, first_name, last_name, film_id
from actor a, film_actor fm
where a.actor_id = fm.actor_id;

##### Doesn't return any results and I have no idea why ######
-- SHORT CUT (NATURAL JOIN)
select customer_id, last_name, rental_id, rental_date
from customer natural join rental;

-- SHORT CUTS JOIN USING
select inv_number, p_code, p_descript, line_units, line_price
from invoice join line using (INV_NUMBER) join product using (P_CODE);

-- JOIN ON (HAVE TO USE ACTUAL JOIN COLUMNS)
select a.actor_id, a.first_name, a.last_name, f.film_id, f.title, f.description
from actor a join film_actor fm on a.actor_id = fm.actor_id
join film f on f.film_id = fm.film_id;
-- join ON
select store.manager_staff_id, staff.last_name, store.store_id
from store join staff on store.manager_staff_id = staff.staff_id
order by staff.last_name;


-- Left Outer Join (customers who don't have rentals will show up) 
select rental_id, c.customer_id, first_name, last_name
from customer c left join rental r on c.customer_id = r.customer_id;

-- Right Outer Join (rentals that dont have customer will show up)
select rental_id, c.customer_id, first_name, last_name
from customer c right join rental r on c.customer_id = r.customer_id;

-- subqueries

select rental_id, rental.customer_id, last_name, first_name
from customer, rental
where customer.customer_id = rental.customer_id;

-- Subquery doesn't work
select v_code, v_name 
from vendor 
where v_code not in (select v_code from product);

-- subquery with where    AWESOME QUERY
select payment_id, amount from payment
where amount >= (select avg(amount) from payment);

-- subquery with where 

select distinct c.customer_id, c.last_name, c.first_name
from customer c join rental using (customer_id)
join inventory using (inventory_id)
join film_actor using (film_id)
join actor using (actor_id)
where actor_id = (select actor_id from actor where last_name='SWANK');

-- Similar
select distinct c.customer_id, c.last_name, c.first_name
from customer c join rental using (customer_id)
join inventory using (inventory_id)
join film_actor using (film_id)
join actor a using (actor_id)
where a.last_name='SWANK';

-- in SubQueries
select distinct c.customer_id, c.last_name, c.first_name
from customer c join rental using (customer_id)
join inventory using (inventory_id)
join film_actor using (film_id)
join actor using (actor_id)
where actor_id in (select actor_id from actor
					where last_name like 'SW&'
					or last_name like '%WAN%');
                    
-- in SubQueries  (SAME)
select distinct c.customer_id, c.last_name, c.first_name
from customer c join rental using (customer_id)
join inventory using (inventory_id)
join film_actor using (film_id)
join actor a using (actor_id)
where a.last_name like 'SW&'
					or a.last_name like '%WAN%';
                    
-- subquery HAVING
select rental_id, sum(amount), AVG(amount)
from payment
group by rental_id
-- where sum(LINE_UNITS) > AVG(LINE_UNITS); -- Can't do this, that is why having
having sum(amount) > (SELECT AVG(amount) from payment);

-- subquery ALL AND ANY
select p_code, p_qoh*p_price
from product
where p_qoh*p_price > ALL(SELECT P_QOH * P_PRICE
						from product 
						where v_code in (select v_code
                        from vendor
                        where v_state='FL'));

-- subquery ANY (DOESN'T Really make sense does it?)
select p_code, p_qoh*p_price
from product
where p_qoh*p_price > ANY(SELECT P_QOH * P_PRICE
						from product 
						where v_code in (select v_code
                        from vendor
                        where v_state='FL'));                        
                        
                        
-- FROM SUBQUERIES

select distinct customer.cus_code, customer.cus_lname 
from customer,
	(select invoice.cus_code from invoice natural join line
    where p_code='13-Q2/P2') CP1,
    (select invoice.cus_code from invoice natural join line
    where p_code='23109-HB') CP2
where customer.cus_code=cp1.cus_code and cp1.cus_code=cp2.cus_code;

-- Attribute LIST SUBQUERIES

select p_code, p_price, (select avg(p_price) from product) as avgprice,
	p_price-(select avg(p_price) from product) as diff
from product;

-- correlated subquery  (Does outer first, then inner. This passes the first P_CODE from outer, and then calcs the average for that product)
select inv_number, line_number, p_code, line_units
from line ls
where ls.line_units > (select avg(line_units)
						from line la
						where la.p_code=ls.p_code);

-- exists query (correlated)   exists is only for subquerys

select cus_code, cus_lname, cus_fname
from customer
where exists (select cus_code from invoice
				where invoice.cus_code=
                customer.cus_code);

-- This doesn't work
select customer.cus_code, cus_lname, cus_fname
from customer, invoice
where invoice.cus_code=
customer.cus_code;

-- Date time queries
SELECT DAYOFMONTH('2001-11-10'), MONTH('2005-03-05');
SELECT ADDDATE('2008-01-02', 31);

select emp_lname, emp_fname, emp_dob, year(emp_dob) as YEARBORN
from emp where year(emp_dob)> 1959;

-- Case SQL Statements
select lower(emp_lname) from emp;
select upper(emp_lname) from emp;
select emp_lname from emp where lower(emp_lname) like 'smi%';

drop table customer_2;
CREATE TABLE CUSTOMER_2 (
CUS_CODE int,
CUS_LNAME varchar(15),
CUS_FNAME varchar(15),
CUS_INITIAL varchar(1),
CUS_AREACODE varchar(3),
CUS_PHONE varchar(8)

);

INSERT INTO CUSTOMER_2 VALUES(345,'Terrell','Justine','H','615','322-9870');
INSERT INTO CUSTOMER_2 VALUES(347,'Olowski','Paul','F',615,'894-2180');
INSERT INTO CUSTOMER_2 VALUES(351,'Hernandez','Carlos','J','723','123-7654');
INSERT INTO CUSTOMER_2 VALUES(352,'McDowell','George',NULL,'723','123-7768');
INSERT INTO CUSTOMER_2 VALUES(365,'Tirpin','Khaleed','G','723','123-9876');
INSERT INTO CUSTOMER_2 VALUES(368,'Lewis','Marie','J','734','332-1789');
INSERT INTO CUSTOMER_2 VALUES(369,'Dunne','Leona','K','713','894-1238');


-- Union Query
select cus_lname, cus_fname, cus_initial, cus_areacode, cus_phone
from customer
union
select cus_lname, cus_fname, cus_initial, cus_areacode, cus_phone from customer_2;

-- Intersect Query (MYSQL DOES NOT SUPPORT)

select cus_code from customer 
where cus_areacode='615' and 
cus_code in (SELECT DISTINCT  cus_code from invoice);

-- minus alternative
select cus_code from customer 
where cus_areacode='615' and 
cus_code not in (SELECT DISTINCT  cus_code from invoice);

-- create view
create view prod_stats as
select v_code, sum(P_QOH*p_price) as totcost, max(P_QOH) as Maxqty,
	MIN(P_QOH) AS MINQTY, AVG(p_qoh) AS AVGQTY
    FROM PRODUCT
    GROUP BY V_CODE;
    
select * from prod_stats;

-- updatable views

-- Triggers (Row level)


CREATE TABLE employees_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employeeNumber INT NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    changedat DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL
);

CREATE TRIGGER before_employee_update 
    BEFORE UPDATE ON emp
    FOR EACH ROW 
 INSERT INTO employees_audit
 SET action = 'update',
     employeeNumber = OLD.emp_num,
     lastname = OLD.emp_lname,
     changedat = NOW();     

show triggers;
UPDATE emp
SET 
    emp_lname = 'Phan'
WHERE
    emp_num = 100;
drop trigger before_employee_update;
-- Triggers (Stemployees_auditatement level)

-- Stored Procedure





