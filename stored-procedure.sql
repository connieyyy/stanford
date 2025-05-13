DELIMITER //

CREATE PROCEDURE add_movie(
    IN movie_title VARCHAR(100),
    IN movie_year INT,
    IN movie_director VARCHAR(100),
    IN star_name VARCHAR(100),
    IN genre_name VARCHAR(32),
    OUT message VARCHAR(200)
)
BEGIN
    DECLARE movie_id VARCHAR(10);
    DECLARE star_id VARCHAR(10);
    DECLARE genre_id INT;
    DECLARE movie_exists INT;

SELECT COUNT(*) INTO movie_exists FROM movies
WHERE title = movie_title AND year = movie_year AND director = movie_director;

IF movie_exists > 0 THEN
        SET message = 'Error: Duplicated movie';
ELSE
SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) INTO @max_id FROM movies WHERE id LIKE 'tt%';
SET movie_id = CONCAT('tt', LPAD(@max_id + 1, 7, '0'));

INSERT INTO movies (id, title, year, director)
VALUES (movie_id, movie_title, movie_year, movie_director);

SELECT id INTO star_id FROM stars WHERE name = star_name LIMIT 1;

IF star_id IS NULL THEN
SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) INTO @max_star_id FROM stars WHERE id LIKE 'nm%';
SET star_id = CONCAT('nm', LPAD(@max_star_id + 1, 7, '0'));

INSERT INTO stars (id, name)
VALUES (star_id, star_name);
END IF;

INSERT INTO stars_in_movies (starId, movieId)
VALUES (star_id, movie_id);

SELECT id INTO genre_id FROM genres WHERE name = genre_name LIMIT 1;

IF genre_id IS NULL THEN
            INSERT INTO genres (name) VALUES (genre_name);
            SET genre_id = LAST_INSERT_ID();
END IF;

INSERT INTO genres_in_movies (genreId, movieId)
VALUES (genre_id, movie_id);

SET message = CONCAT('Success! movieID: ', movie_id, ', starID:', star_id, ', genreID:', genre_id);
END IF;
END //

DELIMITER ;