/* 
Cleaning Data sing SQL Queries
*/

-- 1. Staging: Making a clone of the main table for data cleaning.

create table car_repair_staging
like car_repair;

insert into car_repair_staging
select * from car_repair;


-- 2. Duplicates: searching for duplicates and deleting one of them if found any

-- since there is no row_number in the table we have to add one using a simple CTE:

with duplicate_cte as(
select *,
row_number() over(
partition by `Registration Type` , `Corporation Name` , `Trade Name` , 
  `Business Address` , `Business Address2` , `City` , `State` , `Zip` ,
  `Phone Number` , `# ASE Certified Mechanics` , `Tow Storage Address` ,`Tow Storage 2` ,
  `Tow Storage City` ,`Tow Storage State` , `Tow Storage Zip` ,`Tow Storage Phone` ,`Issue Date` ,
  `Expiration` ,`Registration No.` ,`Location` ) as row_num 
from car_repair_staging );

-- now in order to solve duplicate issue, we make another clone of the table:

CREATE TABLE `car_repair_staging2` (
  `Registration Type` text,
  `Corporation Name` text,
  `Trade Name` text,
  `Business Address` text,
  `Business Address2` text,
  `City` text,
  `State` text,
  `Zip` int DEFAULT NULL,
  `Phone Number` text,
  `# ASE Certified Mechanics` int DEFAULT NULL,
  `Tow Storage Address` text,
  `Tow Storage 2` text,
  `Tow Storage City` text,
  `Tow Storage State` text,
  `Tow Storage Zip` text,
  `Tow Storage Phone` text,
  `Issue Date` text,
  `Expiration` text,
  `Registration No.` text,
  `Location` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Insert into car_repair_staging2
select *,
row_number() over(
partition by `Registration Type` , `Corporation Name` , `Trade Name` , 
  `Business Address` , `Business Address2` , `City` , `State` , `Zip` ,
  `Phone Number` , `# ASE Certified Mechanics` , `Tow Storage Address` ,`Tow Storage 2` ,
  `Tow Storage City` ,`Tow Storage State` , `Tow Storage Zip` ,`Tow Storage Phone` ,`Issue Date` ,
  `Expiration` ,`Registration No.` ,`Location` ) as row_num  
from car_repair_staging;

delete 
from car_repair_staging2
where row_num > 1;


-- 3. Standardizing: First Trimming our data to remove extra spaces

update car_repair_staging2
set `Corporation Name` = trim(`Corporation Name`);

-- Updating abbreviation problem in state column

update car_repair_staging2
set State = 'MD'
where State like '%Maryland%' or State like '%Mryland%' or State like 'MD -%';

-- Changing date time from text to date

Update car_repair_staging2
set `Issue Date` = str_to_date(`Issue Date` , '%m/%d/%Y');

Update car_repair_staging2
set Expiration = str_to_date(Expiration , '%m/%d/%Y');

alter table car_repair_staging2
modify column `Expiration` Date;
alter table car_repair_staging2
modify column `Issue Date` Date;


-- 4. Solving Blank/Null cells: first lets change blank cells to null

update car_repair_staging2
set `Corporation Name` = Null
where `Corporation Name` = '';

update car_repair_staging2
set `Trade Name` = Null
where `Trade Name` = '';

-- now replace those nulls which we can find via other related rows

Update car_repair_staging2 t1
join car_repair_staging2 t2
	on t1.`Trade Name` = t2.`Trade Name`
set t1.`Corporation Name` = t2.`Corporation Name`
where t1.`Corporation Name` IS null
and t2.`Corporation Name` is not null;

-- at the end, dropping the extra column we made already

alter table car_repair_staging2
drop column `row_num`;



-- 5. EDA

-- number of repairs based on city and corporation name
select City , count(`Registration No.`) as number_of_insurances_per_city
from car_repair_staging2
group by city 
order by 2 desc;

select `Trade Name`  , count(`Registration No.`) as number_of_insurances_corps 
from car_repair_staging2
group by `Trade Name`
order by 2 desc;

-- number of insurances issued order by year and month
select substring(`Issue Date`, 1 , 7) as months , count(`Registration No.`) as sum_insurance
from car_repair_staging2
group by substring(`Issue Date`, 1 , 7)
order by 2 desc;

-- rolling some of insurances based on the months of every year using a cte
with rolling_total as
(
select substring(`Issue Date`, 1 , 7) as months , count(`Registration No.`) as insurance_per_month
from car_repair_staging2
group by substring(`Issue Date`, 1 , 7)
)
select months , insurance_per_month,
sum(insurance_per_month) over (order by months desc) as rolling_total
from rolling_total;

-- ranking each corporation had the highest number of insurances issued per year

with corp_year (corps,years,totals) as
(
select `Trade Name` ,Year(`Issue Date`) as years , count(`Registration No.`) as totals
from car_repair_staging2
group by `Trade Name` ,Year(`Issue Date`)
), corp_year_rank as
(
select * , dense_rank() over ( partition by years order by totals desc) as ranking
from corp_year
order by ranking asc
)
select *
from corp_year_rank
order by years desc;

