Drop database if exists as02;
Create database as02;
Use as02;

CREATE TABLE students (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender ENUM('Male', 'Female')
);

CREATE TABLE scores (
    id CHAR(36) PRIMARY KEY,
    math_score INT,
    reading_score INT,
    writing_score INT
);

CREATE TABLE responsibility (
	id CHAR(36) PRIMARY KEY,
    day_present INT,
    number_of_marks INT,
    completed_credits INT 
);
        
SELECT * FROM (
    SELECT 
        s.id,
        s.name,
        s.age,
        s.gender,
        sc.math_score,
        sc.reading_score,
        sc.writing_score,
        r.day_present,
        r.number_of_marks,
        r.completed_credits,
        (SELECT AVG(score) FROM (
            SELECT sc.math_score as score 
            UNION ALL 
            SELECT sc.reading_score 
            UNION ALL 
            SELECT sc.writing_score
        ) AS scores) AS average_score
    FROM students s
    INNER JOIN scores sc ON s.id = sc.id
    INNER JOIN responsibility r ON s.id = r.id
    WHERE s.id IN (
        SELECT id FROM students WHERE age BETWEEN 16 AND 20
    )
    AND sc.id IN (
        SELECT id FROM scores WHERE math_score > 70 OR reading_score > 70
    )
    AND r.id IN (
        SELECT id FROM responsibility WHERE day_present > 100
    )
) AS subquery
WHERE average_score > 60
ORDER BY average_score DESC;

Create index idx_students_age_filter on students(id,age);
Create index idx_math_score on scores(math_score);
Create index idx_reading_score on scores(reading_score);
Create index idx_writing_score on scores(writing_score);
Create index idx_reliability_day on responsibility(id,day_present);
drop index idx_writing_score on scores;
drop index idx_reading_score on scores;
drop index idx_math_score on scores;
Create index all_scores on scores(math_score, reading_score, writing_score, id);
 
WIth filter_students As ( 
	SELECT 
        s.id,
        s.name,
        s.age,
        s.gender,
        sc.math_score,
        sc.reading_score,
        sc.writing_score,
        r.day_present,
        r.number_of_marks,
        r.completed_credits,
        (sc.math_score + sc.reading_score + sc.writing_score) / 3 as average_score
	from students s
    join scores sc on s.id = sc.id 
    join responsibility r on s.id = r.id
    where s.age between 16 and 20 
		and (sc.math_score > 70 or sc.reading_score > 70)
        and r.day_present > 100
        and (sc.math_score + sc.reading_score + sc.writing_score) / 3 > 60 
)
Select * from filter_students 
order by average_score desc;

Create view students_mv as 
SELECT 
	s.id,
	s.name,
	s.age,
	s.gender,
	sc.math_score,
	sc.reading_score,
	sc.writing_score,
	r.day_present,
	r.number_of_marks,
	r.completed_credits,
	(sc.math_score + sc.reading_score + sc.writing_score) / 3 as average_score
from students s
join scores sc on s.id = sc.id 
join responsibility r on s.id = r.id
where s.age between 16 and 20 
	and (sc.math_score > 70 or sc.reading_score > 70)
	and r.day_present > 100
	and (sc.math_score + sc.reading_score + sc.writing_score) / 3 > 60;
Select * from students_mv order by average_score desc;



