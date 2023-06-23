-- A. Declare, calcule e imprima el promedio de antigüedad de Las películas, si es mayor a 15 años
--    imprima 'Cine Clásico, de lo contario ‘Cine Moderno.

DROP FUNCTION IF EXISTS verificar_antiguedad_pelicula();

CREATE OR REPLACE FUNCTION verificar_antiguedad_pelicula(pelicula_nombre VARCHAR)
RETURNS VOID AS
$$
DECLARE
    average_age INT;
    movie_status VARCHAR(20);
BEGIN
    SELECT AVG(CAST(EXTRACT(YEAR FROM current_date) AS INTEGER) - CAST(release_year AS INTEGER))::INT
    INTO average_age
    FROM film
    WHERE title = pelicula_nombre;
    
    IF average_age IS NULL THEN
        RAISE NOTICE 'No se encontró la película con el nombre: %', pelicula_nombre;
        RETURN;
    ELSIF average_age > 15 THEN
        movie_status := 'Cine Clásico';
    ELSE
        movie_status := 'Cine Moderno';
    END IF;

    RAISE NOTICE 'Promedio de antigüedad de la película "%": % años', pelicula_nombre, average_age;
    RAISE NOTICE 'Estado de la película "%": %', pelicula_nombre, movie_status;
END;
$$
LANGUAGE plpgsql;

SELECT verificar_antiguedad_pelicula('African Egg');

SELECT title, release_year FROM film;

-- B. 
