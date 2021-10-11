--Employee Database Challenge Deliverbale 1

--retrieve information from employee table
SELECT emp_no, first_name, last_name
FROM employees;

--retrieve information from titles table
SELECT title, from_data, to_date
FROM titles;

--Insert those eligigble for retirement into their own table, with most current title
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, from_date, to_date
INTO retirement_titles
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31') 
ORDER BY emp.emp_no, titles.to_date DESC;

--Create a unique titles table
Select emp_no, first_name, last_name, title
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

--Number of employees with each title eligible for retirement (i.e. retiring titles)
SELECT COUNT(title) AS title_count, title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY title_count DESC;

--Deliverable 2: Create a table that determines if an active employee is eligible to be a mentor based on birth date.
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, dept.dept_name, emp_department.from_date, emp_department.to_date
INTO mentorship_eligibilty
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE (birth_date BETWEEN '1965-01-01' AND '1965-12-31') AND emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no, emp_department.to_date DESC;

--Taking Deliverable 2 one step further:
--Create table that has time in department and tenure, in order to determine if they can participate as a mentor based on years of experience
    --in the organization, as well as in their department
SELECT DISTINCT ON (emp.emp_no) emp.emp_no, first_name, last_name, title, 
	dept.dept_name, (DATE_PART('year', '2002-09-01'::date)-DATE_PART('year',emp_department.from_date)) AS Time_In_Dept, (DATE_PART('year', '2002-09-01'::date) - DATE_PART('year', hire_date)) AS Tenure,
    CASE
        WHEN ((DATE_PART('year', '2002-09-01'::date) - DATE_PART('year', hire_date)) >= 10 AND (DATE_PART('year', '2002-09-01'::date)-DATE_PART('year',emp_department.from_date)) > 5)
        THEN 'Mentor Eligible'
    END Mentorship_Eligibility
INTO mentorship_participation
FROM employees as emp LEFT JOIN titles AS titles
	ON emp.emp_no = titles.emp_no
	LEFT JOIN emp_dep as emp_department
	ON emp_department.emp_no = emp.emp_no
	LEFT JOIN departments as dept
	ON emp_department.dept_no = dept.dept_no
WHERE emp_department.to_date = '9999-01-01'
ORDER BY emp.emp_no,emp_department.to_date DESC;

--Get the number of total employees eligible for being a mentor
--They have 15 or more years of tenure in the organization, and 10 or more years in their department
SELECT mentorship_eligibility, COUNT(mentorship_eligibility) as mentorship_eligibility
FROM mentorship_participation
WHERE mentorship_eligibility LIKE 'Mentor Eligible'
GROUP BY mentorship_eligibility;




