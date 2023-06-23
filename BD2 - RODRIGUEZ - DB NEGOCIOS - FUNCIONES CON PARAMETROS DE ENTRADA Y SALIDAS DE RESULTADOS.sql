-- A. Construya un programa sql que devuelva la razón social, dirección y teléfono de abastecimiento de
-- los proveedores que abastecen un determinado producto.

DROP FUNCTION obtener_abastecedores(integer) 

CREATE OR REPLACE FUNCTION obtener_abastecedores(p_id_producto INTEGER)
RETURNS TABLE (
    razonsocial VARCHAR(40),
    direccion VARCHAR(60),
    telefono VARCHAR(25)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT p.NomProveedor, p.DirProveedor, p.fonoProveedor
    FROM Compras.productos pr
    INNER JOIN Compras.proveedores p ON pr.IdProveedor = p.IdProveedor
    WHERE pr.IdProducto = p_id_producto;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obtener_abastecedores(1);

-- B. Elabore un programa sql que devuelva el total de órdenes generadas a un cliente en un
-- determinado trimestre de un determinado año.

DROP FUNCTION IF EXISTS obtener_total_ordenes(character varying, integer, integer);

CREATE OR REPLACE FUNCTION obtener_total_ordenes(p_id_cliente VARCHAR(5), p_trimestre INT, p_anio INT)
RETURNS TABLE (cliente_nombre VARCHAR(40), cliente_id VARCHAR(5), total_ordenes INT)
AS $$
BEGIN
    RETURN QUERY
    SELECT c.NomCliente, c.IdCliente, COUNT(pc.IdPedido)::INT
    FROM Ventas.clientes c
    LEFT JOIN Ventas.pedidoscabe pc ON c.IdCliente = pc.IdCliente
    WHERE c.IdCliente = p_id_cliente
    AND EXTRACT(QUARTER FROM pc.FechaPedido) = p_trimestre
    AND EXTRACT(YEAR FROM pc.FechaPedido) = p_anio
    GROUP BY c.NomCliente, c.IdCliente;

    RAISE NOTICE 'Se encontraron % orden(es) generada(s) al cliente % en el trimestre % del año %', (SELECT COUNT(*) FROM Ventas.pedidoscabe WHERE IdCliente = p_id_cliente AND EXTRACT(QUARTER FROM FechaPedido) = p_trimestre AND EXTRACT(YEAR FROM FechaPedido) = p_anio), p_id_cliente, p_trimestre, p_anio;
END;
$$ LANGUAGE plpgsql;

SELECT obtener_total_ordenes('BONAP', 2, 2010) AS total_ordenes;

-- Para corroborar
SELECT c.NomCliente, c.IdCliente, pc.*, pc.FechaPedido
FROM Ventas.clientes c
JOIN Ventas.pedidoscabe pc ON c.IdCliente = pc.IdCliente
WHERE EXTRACT(YEAR FROM pc.FechaPedido) = 2010;

-- C. Elabore un programa sql que devuelva en qué pedido, fechas y qué razón social de cliente han
-- adquirido un determinado producto.

DROP FUNCTION IF EXISTS obtener_detalles_producto(character varying);

CREATE OR REPLACE FUNCTION obtener_detalles_producto(p_nom_producto VARCHAR(40))
RETURNS TABLE (
    pedido_id INT,
    fecha_pedido TIMESTAMP,
    razon_social_cliente VARCHAR(40)
)
AS $$
DECLARE
    cantidad_pedidos INT;
BEGIN
    RETURN QUERY
    SELECT pc.IdPedido, pc.FechaPedido, c.NomCliente
    FROM Ventas.pedidosdeta pd
    JOIN Ventas.pedidoscabe pc ON pc.IdPedido = pd.IdPedido
    JOIN Ventas.clientes c ON pc.IdCliente = c.IdCliente
    JOIN Compras.productos p ON pd.IdProducto = p.IdProducto
    WHERE p.NomProducto = p_nom_producto;

    GET DIAGNOSTICS cantidad_pedidos = ROW_COUNT;
    RAISE NOTICE 'Se encontraron % pedido(s) para el producto: %', cantidad_pedidos, p_nom_producto;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obtener_detalles_producto('Sirope de regaliz');

SELECT NomProducto
FROM Compras.productos;


