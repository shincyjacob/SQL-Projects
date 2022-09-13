select * from t_employees
limit 10;

select * from t_dept_emp
limit 10;

select * from t_departments;


-- 1 : Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990. 
select year(de.from_date) year, e.gender gender, count(de.emp_no) num_of_emp
from t_dept_emp de
join t_employees e
on de.emp_no = e.emp_no
group by 1,2
having year(de.from_date) >= 1990
order by 1 desc;


-- 2 : Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;


-- 3 : Compare the average salary of female versus male employees in the entire company until year 2002, add a filter allowing you to see that per each department.

select year(s.from_date) year, e.gender, dept.dept_name, round(avg(s.salary),2) salaries
from t_employees e
join t_salaries s
on e.emp_no = s.emp_no
join t_dept_emp de
on de.emp_no = e.emp_no
join t_departments dept
on dept.dept_no = de.dept_no
where year(s.from_date) <= 2002
group by 1,2,3
order by 1,3; 


-- 4 : Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. 
-- Let this range be defined by two values the user can insert when calling the procedure.

DROP PROCEDURE IF EXISTS dept_avg_salary;
DELIMITER $$ 
CREATE PROCEDURE dept_avg_salary(IN p_range_a DECIMAL(10,2), IN p_range_b DECIMAL(10,2))
BEGIN
    SELECT e.gender, dept.dept_name, round(avg(s.salary),2) salaries
	from t_employees e
	join t_salaries s
	on e.emp_no = s.emp_no
	join t_dept_emp de
	on de.emp_no = e.emp_no
	join t_departments dept
	on dept.dept_no = de.dept_no
    where s.salary between p_range_a and p_range_b
    group by 1,2;
END$$
DELIMITER ;
call dept_avg_salary(50000,90000);

# Tableau visualization link :
-- https://public.tableau.com/app/profile/shincy.jacob/viz/EmployeesalaryanalysisSQL-Tableau/Dashboard1

