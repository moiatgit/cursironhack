-- 1. Display available tables
show tables;

-- 2. Retrieve data from actor, film and customer
select * from actor;
select * from film;
select * from customer;

-- 3.1. Retrieve titles of films

select title from film;

-- 3.2. Languages used in films as language
--      I'm assuming all languages in language table are used in films since all the questions in 3.x are about one table

select name as language from language;


-- 3.3. First names of employees from staff

select first_name from staff;

-- 4. Unique release years

select distinct release_year from film;

-- 5.1. number of stores

select count(*) from store;

-- 5.2. number of employees

select count(*) from staff;

-- 5.3. number of films available for rent and number of rented ones

-- I assume the films in inventory are the ones available

select count(*) from inventory;

-- I assume the films in rental are the one

select count(*) from film;

-- 5.4. number of distinct last names of actors

select distinct last_name from actor;

-- 6. 10 longest films

select title, length from film order by length desc limit 10;

-- 7.1. actors with first name 'SCARLETT'

select * from actor where first_name = 'SCARLETT';

-- 7.2. Movies that have ARMAGEDDON in their title and are longer than 100 min

select title, length from film where title like '%ARMAGEDDON%' and length > 100;

-- 7.3. number of films with Behind the Scenes content

select * from film where special_features = 'Behind the Scenes';
