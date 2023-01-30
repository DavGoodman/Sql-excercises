--CHAPTER 8 Refining selections-------------------------------------------------------------------------------

--1: Select all story collections
SELECT
    title 
        FROM books WHERE title LIKE '%stories%';

--2: Find the longest book
SELECT 
    title, pages
        FROM books
            ORDER BY pages DESC LIMIT 1;

--3: Print a summary containing the title and year for the 3 most recent books
SELECT CONCAT(
    title, ' - ', released_year) AS summary
        FROM books
            ORDER BY released_year DESC LIMIT 3;

--4 Find all books with an author_lname that contains a space(' ')
SELECT 
    title, author_lname
        FROM books
            WHERE author_lname LIKE '% %';

--5 Find the 3 books with the lowest stock quantity
SELECT 
    title, released_year, stock_quantity
        FROM books
            ORDER BY stock_quantity LIMIT 3;

--6 Print title and author_lname, sorted first by author_lname thne by title.
SELECT 
    title, author_lname
        FROM books
            ORDER BY author_lname, title;

--7 Make this happen sorted alphabetically by last name
SELECT CONCAT(
    'MY FAVORITE AUTHOR IS ', UPPER(author_fname), ' ', UPPER(author_lname), '!')
        FROM books
            ORDER BY author_lname;





--CHAPTER 9 Aggregate functions-------------------------------------------------------------------------------

--1 print the number of books in the database
SELECT COUNT(*) FROM books;

--2 print out how many books were relseased in each year
SELECT released_year, COUNT(*) FROM books GROUP BY released_year;

--3 print out total number of books in stock
SELECT SUM(stock_quantity) FROM books;

--4 find the average released_year for each author
SELECT 
    CONCAT(author_fname, ' ', author_lname) AS author, AVG(released_year)
        FROM books GROUP BY author;

--5 find the full name of the author who wrote the longest book
SELECT 
    CONCAT(author_fname, ' ', author_lname), title, pages 
        FROM books WHERE pages = (SELECT MAX(pages) FROM books);

--6 print year, books from year and avg pages from books in each year
SELECT 
    released_year AS year, COUNT(*) AS books, AVG(pages) AS avg_pages 
        FROM books GROUP BY released_year ORDER BY released_year;





--CHAPTER 10 Data types-------------------------------------------------------------------------------

--1: WHat is a good use case for Char?
-- Char() is best used for when you know exactly how many chars will be in a table
-- such as state abbreviations NY, NJ, OK etc..

--2: fill in blanks (the value types)
CREATE TABLE inventory (
    item_name VARCHAR(50),
    price DECIMAL(8,2),
    quantity SMALLINT
)

--3: Explain the difference between datetime and timestamp
-- they are effectively the same however timestamp has a shorter
-- min and max value and takes up fewer bytes

--4 print out the current date and time
SELECT CURDATE(), CURTIME();

--5 print out current day of the week as a number
SELECT DAYOFWEEK(CURDATE());

--6 print out current day and time using this format:
-- mm/dd/yyyy
SELECT DATE_FORMAT(CURDATE(), '%m/%d/%Y');
-- and
-- January 2nd at 3:15 || April 1st at 10:18
SELECT DATE_FORMAT(NOW(), '%M %D at %k:%i');

--7 create a tweets table
CREATE TABLE tweets(
    tweet_content VARCHAR(180),
    username VARCHAR(20),
    created_at TIMESTAMP default CURRENT_TIMESTAMP
);



--CHAPTER 11 Data types-------------------------------------------------------------------------------

--1 select all books written between 1980(non inclusive)
SELECT * FROM books WHERE released_year < 1980;

--2 select all books written by Eggers or Chabon
SELECT * FROM books WHERE author_lname IN ('Eggers', 'Chabon');

--3 select all books written by Lahiri, published after 2000
SELECT * FROM books WHERE author_lname = 'Lahiri' AND released_year > 2000;

--4 select all books with page counts between 100 and 200
SELECT * FROM books WHERE pages BETWEEN 100 AND 200;

--5 select all books where author_lname starts with a 'C' or an 'S'
SELECT * FROM books WHERE LEFT(author_lname, 1) IN ('C', 'S');

--6 
-- if title contains 'stories' -> Short Stories
-- Just Kids and A Heartbreaking Work -> Memoir
-- Everything else -> Novel
DESC books;
SELECT title, author_lname, CASE 
	WHEN title LIKE '%stories%' THEN 'Short Stories'
	WHEN title='Just Kids' OR title='A Heartbreaking Work of Staggering Genius' THEN 'Memoir'
    ELSE 'Novel'
	END AS Type
 FROM books;

--7 print out authors and how many books they wrote printing "book" if 1 and "books" if 2 or more
SELECT author_fname, author_lname, 
    CONCAT(COUNT(*), CASE WHEN COUNT(*) = 1 THEN ' book' ELSE ' books' END) AS Count
        FROM books GROUP BY author_fname, author_lname;


--CHAPTER 12 Constraints-------------------------------------------------------------------------------
-- no excercises this chapter :(




--CHAPTER 13 One to many joins-------------------------------------------------------------------------------

--1 write a schema for students and papers with papers referencing a foreign key from students
CREATE TABLE students(
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20)
);

CREATE TABLE papers(
    title VARCHAR(50),
    grade INT,
    student_id INT,
    FOREIGN KEY (student_id) REFERENCES students(id)
)

--2 print excercise
SELECT first_name, title, grade FROM students 
    JOIN papers ON students.id = papers.student_id
        ORDER BY grade DESC;

--3 same as 2 but print all students regardless if they have written a paper
SELECT first_name, title, grade FROM students 
    LEFT JOIN papers ON students.id = papers.student_id;

--4 replace Nulls with 'Missing' or 0 in excercise 3
SELECT first_name, IFNULL(title, 'MISSING'), IFNULL(grade, 0) FROM students 
    LEFT JOIN papers ON students.id = papers.student_id;


--5 print name and average scores
SELECT first_name, IFNULL(AVG(grade), 0) AS average FROM students 
    LEFT JOIN papers ON students.id = papers.student_id
        GROUP BY first_name ORDER BY average DESC;

--6 print wether student is passing or failing based if their avg score is above 75
SELECT first_name, IFNULL(AVG(grade), 0) AS average, 
CASE WHEN IFNULL(AVG(grade), 0) > 75 THEN 'PASSING' ELSE 'FAILING' END AS passing_status
    FROM students 
    LEFT JOIN papers ON students.id = papers.student_id
        GROUP BY first_name ORDER BY average DESC;



--CHAPTER 13 many to many-------------------------------------------------------------------------------

--1 print all reviews with title and ratings next to each other
SELECT title, rating 
    FROM series 
    JOIN reviews ON reviews.series_id = series.id;

--2 print avg ratings of all shows
SELECT title, ROUND(AVG(rating), 2) AS avg_rating
    FROM series 
    JOIN reviews ON reviews.series_id = series.id
        GROUP BY title ORDER BY avg_rating;

--3 print all reviews along side their reviewers
SELECT first_name, last_name, rating
    FROM reviewers 
    JOIN reviews ON reviews.reviewer_id = reviewers.id;

--4 print all series with no reviews
SELECT title AS unreviewed_series
    FROM series
    LEFT JOIN reviews ON reviews.series_id = series.id
    WHERE rating IS NULL;

--5 get avg ratings for each genre
SELECT genre, AVG(rating)
    FROM series
    JOIN reviews ON reviews.series_id = series.id
    GROUP BY genre;

--6 print reviewers and ther review count, smallest and largest review score
-- average review score and set statues inactive if they have no reviews
SELECT 
    first_name,
    last_name,
    COUNT(rating) AS COUNT,
    IFNULL(MIN(rating), 0) AS MIN,
    IFNULL(MAX(rating), 0) AS MAX,
    ROUND(IFNULL(AVG(rating),0),2) AS AVG,
    CASE
        WHEN MAX(rating) IS NULL THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END AS STATUS
FROM reviewers
        LEFT JOIN
		reviews ON reviews.reviewer_id = reviewers.id
			GROUP BY first_name, last_name;

--7 print all reviews with title and reviewer displayed
SELECT 
	title, rating, CONCAT(first_name, ' ', last_name) AS reviewer
		FROM reviews
        JOIN series ON series.id = series_id
        JOIN reviewers ON reviewers.id = reviewer_id
        ORDER BY title;


