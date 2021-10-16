--Employee Database Challenge Deliverbale 1

--Insert those eligigble for retirement into their own table
SELECT emp.emp_no, first_name, last_name, title, from_date, to_date
INTO retirement_titles
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
ORDER BY emp.emp_no;

--Create a unique titles table from those eligible to retire
Select DISTINCT ON(emp_no) emp_no, first_name, last_name, title
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

--Number of employees with each title eligible for retirement (i.e. retiring titles)
SELECT COUNT(title) AS title_count, title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY title_count DESC;

---------- One Step Further -------
--Getting total number of current employees, to determine the percentage of retirements (240,124 employees)
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO current_employees
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, titles.to_date DESC;

SELECT COUNT(emp_no) AS Number_Emp
FROM current_employees;

--Get number of employees eligible to retire (90,398)
SELECT COUNT(emp_no)
FROM unique_titles;

--37.64% of the workforce is eligible to retire

--Insert those eligible for retirement, that are still currently active, into their own table with with current title and department
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO retirement_titles_v2
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, titles.to_date DESC;

---Insert those not eligible for retirement, that are still currently active, into their own table with current title and department
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO retirement_titles_v2
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') AND emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, titles.to_date DESC;

--Create a table that counts the number of titles retiring per department, in addition calculating the number of positions to fill accounting for a 15% attrition
SELECT dept_name, title, COUNT(title) AS Positions_Retiring, (COUNT(title)-ROUND((COUNT(title)*.15))) AS Positions_to_fill
INTO retiring_titles_count
FROM retirement_titles_v2
GROUP BY dept_name, title
ORDER BY dept_name, title;

--Create a table that counts the number of titles of those not retiring and still active per department.
SELECT dept_name, title, COUNT(title) AS Current_Positions
INTO current_titles_count
FROM nonretirement_titles 
GROUP BY dept_name, title
ORDER BY dept_name, title;


--Create a career progression table, import career_progression.csv file in order to see what lower level positions feed into higher level positions
CREATE TABLE position_progression (
dept_no VARCHAR(4) NOT NULL,
	lower_title VARCHAR NOT NULL,
    upper_title VARCHAR NOT NULL,
FOREIGN KEY (dept_no) REFERENCES departments (dept_no)
);

--Join the count tables with the career progression table to see workforce planning
SELECT dep.dept_name, cur.title AS lower_title_available, cur.number_in_position_currently AS current_count, 
	ret.title AS upper_title_retiring, ret.positions_to_fill,
CASE
		WHEN (COALESCE(cur.number_in_position_currently,0)-ret.positions_to_fill) <= 0
        THEN 'External Hires Needed'
		WHEN (COALESCE(cur.number_in_position_currently,0)-ret.positions_to_fill) > 0
        THEN 'Mentor to Promote'
    END Workforce_Planning
--INTO workforce_planning
FROM position_progression AS pp 
	--get department name
	JOIN departments as dep ON pp.dept_no = dep.dept_no
	--get count of retiring higher level positions
	JOIN retiring_titles_count AS ret ON pp.upper_title = ret.title AND dep.dept_name = ret.dept_name
	--get count of current lower level positions
	LEFT JOIN current_titles_count AS cur ON pp.lower_title = cur.title AND dep.dept_name = cur.dept_name
ORDER BY workforce_planning, dep.dept_name;

------------------------------------

--Deliverable 2: Create a table that determines if an active employee is eligible to be a mentor based on birth date.
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO mentorship_eligibility
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31') AND emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, emp_department.to_date DESC;

--Getting the count per dept, per title
SELECT dept_name, title, COUNT(title) AS Number_in_Position
FROM mentorship_eligibility
GROUP BY dept_name, title
ORDER BY dept_name, title;

--Broadening the scope of those eligible to be a mentor, based on birth date
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO mentorship_eligibility_v2
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1965-12-31') AND emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, emp_department.to_date DESC;

--Getting the count per dept, per title
SELECT dept_name, title, COUNT(title) AS Number_in_Position
FROM mentorship_eligibility_v2
GROUP BY dept_name, title
ORDER BY dept_name, title;
