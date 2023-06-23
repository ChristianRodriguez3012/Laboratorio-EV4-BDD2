-- 1. Elabore una función que devuelva el total de pedidos generados a un cliente en un
-- determinado trimestre de un determinado año.

-- Eliminar la función 'obtener_total_pedidos_trimestre'
DROP FUNCTION IF EXISTS obtener_total_pedidos_trimestre(character varying, integer, integer);

-- Definición de la función que obtiene el total de pedidos generados a un cliente en un determinado trimestre de un año específico.
CREATE OR REPLACE FUNCTION obtener_total_pedidos_trimestre(
    cliente_id VARCHAR(5), -- Identificador del cliente
    anio_param INT, -- Año del cual se desea obtener el total de pedidos
    trimestre_param INT -- Trimestre del cual se desea obtener el total de pedidos
)
RETURNS TABLE (
    total_pedidos INT,
    mensaje TEXT
) AS $$
DECLARE
    fecha_inicio DATE; -- Fecha de inicio del trimestre
    fecha_fin DATE; -- Fecha de fin del trimestre
BEGIN
    -- Determinar las fechas de inicio y fin del trimestre
    CASE trimestre_param
        WHEN 1 THEN
            fecha_inicio := TO_DATE(anio_param || '-01-01', 'YYYY-MM-DD'); -- Primero de enero del año
            fecha_fin := TO_DATE(anio_param || '-03-31', 'YYYY-MM-DD'); -- 31 de marzo del año
        WHEN 2 THEN
            fecha_inicio := TO_DATE(anio_param || '-04-01', 'YYYY-MM-DD'); -- Primero de abril del año
            fecha_fin := TO_DATE(anio_param || '-06-30', 'YYYY-MM-DD'); -- 30 de junio del año
        WHEN 3 THEN
            fecha_inicio := TO_DATE(anio_param || '-07-01', 'YYYY-MM-DD'); -- Primero de julio del año
            fecha_fin := TO_DATE(anio_param || '-09-30', 'YYYY-MM-DD'); -- 30 de septiembre del año
        WHEN 4 THEN
            fecha_inicio := TO_DATE(anio_param || '-10-01', 'YYYY-MM-DD'); -- Primero de octubre del año
            fecha_fin := TO_DATE(anio_param || '-12-31', 'YYYY-MM-DD'); -- 31 de diciembre del año
        ELSE
            RAISE EXCEPTION 'Trimestre inválido: %', trimestre_param; -- Lanzar una excepción si el trimestre no es válido
    END CASE;

    -- Calcular el total de pedidos en el trimestre especificado
    SELECT COUNT(*), 'El total de pedidos para el cliente ' || cliente_id || ' en el trimestre ' || trimestre_param || ' del año ' || anio_param || ' es: ' || COUNT(*)
    INTO total_pedidos, mensaje
    FROM Ventas.pedidoscabe
    WHERE idcliente = cliente_id
        AND EXTRACT(QUARTER FROM fechaPedido) = trimestre_param -- Obtener el trimestre de la fecha de pedido
        AND EXTRACT(YEAR FROM fechaPedido) = anio_param; -- Obtener el año de la fecha de pedido

    RETURN NEXT;

    RAISE NOTICE '%', mensaje;
END;
$$ LANGUAGE plpgsql;

-- Llamada a la función para obtener el total de pedidos para el cliente 'ALFKI' en el segundo trimestre del año 1997
SELECT * FROM obtener_total_pedidos_trimestre('ALFKI', 1997, 2);





-- 2. Elabore una función que elimine un determinado cliente, si éste no ha generado Pedido alguno.

-- Eliminar la función 'eliminar_cliente_sin_pedidos'
DROP FUNCTION IF EXISTS eliminar_cliente_sin_pedidos(character varying);

-- Definición de la función que elimina un cliente si no ha generado ningún pedido
CREATE OR REPLACE FUNCTION eliminar_cliente_sin_pedidos(
    cliente_id VARCHAR(5) -- Identificador del cliente a eliminar
)
RETURNS VOID AS $$
DECLARE
    total_pedidos INT; -- Variable para almacenar el total de pedidos
BEGIN
    -- Verificar si el cliente tiene algún pedido
    SELECT COUNT(*)
    INTO total_pedidos
    FROM Ventas.pedidoscabe
    WHERE idcliente = cliente_id;

    -- Si el cliente no tiene ningún pedido, eliminarlo
    IF total_pedidos = 0 THEN
        DELETE FROM Ventas.clientes
        WHERE idcliente = cliente_id;
        
        RAISE NOTICE 'El cliente % ha sido eliminado debido a que no ha generado ningún pedido.', cliente_id;
    ELSE
        RAISE NOTICE 'El cliente % tiene pedidos registrados y no puede ser eliminado.', cliente_id;
    END IF;
    
    RAISE NOTICE 'El cliente % ha sido eliminado correctamente.', cliente_id;
END;
$$ LANGUAGE plpgsql;

-- Llamada a la función para eliminar el cliente 'ALFKI' si no ha generado ningún pedido
SELECT eliminar_cliente_sin_pedidos('ALFKI');

SELECT * FROM productos;





-- 3. Crear un cursor que permita aumentar el precio unitario de un producto según la tabla.
-- 		Proveedor 1 y Categoria 4 --- incrementar en 10%
-- 		Proveedor 3 y Categoria 2 --- incrementar en 15%
-- 		Proveedor 2 y Categoria 5 --- incrementar en 20%
CREATE OR REPLACE FUNCTION incrementar_precio_unitario()
  RETURNS VOID AS
$BODY$
DECLARE
  cur CURSOR FOR
    SELECT p.idproducto, p.preciounidad, p.idproveedor, p.idcateria
    FROM compras.productos p;
  rec RECORD;
BEGIN
  OPEN cur;
  LOOP
    FETCH cur INTO rec;
    EXIT WHEN NOT FOUND;

    IF rec.idproveedor = 1 AND rec.idcateria = 4 THEN
      UPDATE compras.productos
      SET preciounidad = rec.preciounidad * 1.1
      WHERE idproducto = rec.idproducto;
      RAISE NOTICE 'ID Producto: %, Precio Unitario anterior: %, Nuevo Precio Unitario: %', rec.idproducto, rec.preciounidad, rec.preciounidad * 1.1;
    ELSIF rec.idproveedor = 3 AND rec.idcateria = 2 THEN
      UPDATE compras.productos
      SET preciounidad = rec.preciounidad * 1.15
      WHERE idproducto = rec.idproducto;
      RAISE NOTICE 'ID Producto: %, Precio Unitario anterior: %, Nuevo Precio Unitario: %', rec.idproducto, rec.preciounidad, rec.preciounidad * 1.15;
    ELSIF rec.idproveedor = 2 AND rec.idcateria = 5 THEN
      UPDATE compras.productos
      SET preciounidad = rec.preciounidad * 1.2
      WHERE idproducto = rec.idproducto;
      RAISE NOTICE 'ID Producto: %, Precio Unitario anterior: %, Nuevo Precio Unitario: %', rec.idproducto, rec.preciounidad, rec.preciounidad * 1.2;
    END IF;
    
  END LOOP;

  CLOSE cur;

  -- Mostrar los resultados finales después de la actualización
  RAISE NOTICE 'Precios unitarios actualizados:';
  PERFORM p.idproducto, p.preciounidad AS "Precio Anterior", 
         CASE 
           WHEN p.idproveedor = 1 AND p.idcateria = 4 THEN p.preciounidad * 1.1
           WHEN p.idproveedor = 3 AND p.idcateria = 2 THEN p.preciounidad * 1.15
           WHEN p.idproveedor = 2 AND p.idcateria = 5 THEN p.preciounidad * 1.2
           ELSE p.preciounidad
         END AS "Nuevo Precio"
  FROM compras.productos p;

END;
$BODY$
LANGUAGE plpgsql;

SELECT incrementar_precio_unitario();
