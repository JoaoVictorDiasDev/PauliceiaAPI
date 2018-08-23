--(a) Corrigir as coordenadas (x,y) de todos os places que estão
--no sistema métrico. Exemplo: o place de número 200 deve estar a
--200 metros do início da rua.

CREATE OR REPLACE FUNCTION update_geometry(input_p integer) 
    RETURNS text
AS
$BODY$
DECLARE 
    street_id Integer := (SELECT street.id FROM tb_places AS places INNER JOIN tb_street AS street ON places.id_street = street.id WHERE places.id = input_p);
    zero_geom text := (SELECT places.geom FROM tb_places AS places INNER JOIN tb_street AS street ON places.id_street = street.id WHERE places.number = 0 AND street.id = street_id);
    street_geom text := (SELECT geom FROM tb_street WHERE id = street_id);
    number_place Integer := (SELECT number FROM  tb_places WHERE id = input_p);
    old_geom_place text := (SELECT geom FROM  tb_places WHERE id = input_p);
    new_geom text := (SELECT st_endpoint(st_intersection(st_setsrid(st_buffer(zero_geom, number_place), 4326), street_geom)));
BEGIN
    IF new_geom IS NOT NULL THEN
        RETURN new_geom;
    ELSE
        RETURN old_geom_place;
    END IF;
END;
$BODY$
LANGUAGE plpgsql;

SELECT update_geometry(622);

--(b) Corrigir as coordenadas (x,y) de todos os places que não estão
--no sistema métrico e que estão na mesma localização dos places
--do item (a), levando em consideração números ímpares e pares
--nas mesmas localizações
       