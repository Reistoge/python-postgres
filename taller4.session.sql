-- CREACION DE TABLAS
CREATE TABLE proveedor (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  telefono TEXT NOT NULL
);

CREATE TABLE producto (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  id_proveedor INT REFERENCES proveedor(id)
);

CREATE TABLE almacen (
  id SERIAL PRIMARY KEY,
  ubicacion TEXT NOT NULL
);

CREATE TABLE inventario (
  id SERIAL PRIMARY KEY,
  id_producto INT REFERENCES producto(id),
  id_almacen INT REFERENCES almacen(id),
  stock INT NOT NULL,
  fecha timestamp 
);
create table alerta_inventario(
	id_alerta serial,
	id_inventario int references inventario(id),
	stock_alerta int,
	fecha_actualizacion timestamp
	
);
-- INSERCION DE DATOS
-- Proveedores
INSERT INTO proveedor (nombre, telefono) VALUES
('Distribuidora El Pauliño', '912345678'),--1
('Importadora NotChaid Ltda.', '987654321'),--2
('Ucenin Corp.', '831676301'),--3
('Suministros PoulCorp', '923456789'),--4
('Distribuidora Don Juan', '911223344'),--5
('Importadora El Sur Ltda.', '922334455'),--6
('Bazar UCN Global', '933445566'),--7
('Poul Supplies S.A.', '944556677');--8


-- Productos
INSERT INTO producto (nombre, id_proveedor) VALUES
('Mate Tradicional', 1), --1
('Yerba Extra Fuerte', 2),--2
('Café Instantáneo', 3),--3
('Azúcar Blanca', 2),--4
('Galletas Dulces', 1),--5
('Té Verde Premium', 1),--6
('Leche en Polvo Entera', 2),--7
('Café Molido Intenso', 3),--8
('Sal Rosada del Himalaya', 2),--9
('Galletas Integrales', 4);--10

-- Almacenes
INSERT INTO almacen (ubicacion) VALUES
('Vallenar'),--1
('Coquimbo'),--2
('La Serena'),--3
('Ovalle'),--4
('Antofagasta'),--5
('Iquique'),--6
('Copiapó'),--7
('La Calera');--8

-- Inventario
INSERT INTO inventario (id_producto, id_almacen, stock, fecha) VALUES
(1, 1, 120, '2024-01-01'),
(1, 2, 80, '2024-01-03'),
(2, 2, 30, '2024-01-04'),
(3, 3, 0, '2024-01-05'),
(4, 1, 70, '2025-01-06'),
(5, 1, 0, '2025-01-06'),
(2, 1, 55, '2025-01-08'),
(2, 3, 90, '2025-01-08'),
(1, 3, 50, '2025-01-07'),
(3, 1, 40, '2025-01-09'),
(3, 2, 95, '2024-01-09'),
(4, 2, 15, '2024-01-10'),
(4, 3, 75, '2024-01-10'),
(5, 1, 105, '2024-03-01'),
(7, 2, 75, '2024-03-05'),
(10, 3, 25, '2024-03-08'),
(9, 4, 5, '2024-03-10'),
(4, 2, 95, '2025-04-12'),
(6, 5, 0, '2025-04-15'),
(8, 7, 60, '2025-04-18'),
(10, 6, 110, '2025-04-20'),
(7, 8, 45, '2025-04-21'),
(8, 6, 38, '2025-04-22'),
(9, 5, 99, '2024-04-23'),
(6, 4, 8, '2024-04-24'),
(8, 7, 67, '2024-04-25')


 
-- CONSULTAS

-------------------------------------------------------------------------------
-- Solo productos con stock en al menos un almacén
select p.id producto_id,nombre, sum(stock) stock_producto from producto p
left join inventario i on p.id = i.id_producto
group by p.id
having sum(stock) > 0
-------------------------------------------------------------------------------
-- Todos los productos, mostrando stock si existe
select p.id producto_id,nombre, sum(stock) stock_producto from producto p
left join inventario i on p.id = i.id_producto
group by p.id
-------------------------------------------------------------------------------
--Todos los almacenes, mostrando productos si existen
select id_almacen,ubicacion, case 
when productos is null then 'No hay productos'
else productos
end as productos
from (
select a.id id_almacen ,ubicacion, string_agg(nombre, ', ') productos from almacen a
left join inventario i on a.id = i.id_almacen
left join producto p on p.id = i.id_producto
group by a.id ,ubicacion) 
-------------------------------------------------------------------------------
--Mostrar stock por almacén, incluyendo ceros para ausencia de registro.
-- (productos que no tienen registros de stock en un almacén.)

select a.ubicacion, p.nombre as producto, 
       coalesce(i.stock, 0) as stock -- 🗿
from almacen a
cross join producto p
left join inventario i 
  on i.id_producto = p.id and i.id_almacen = a.id
order by a.ubicacion, p.nombre;
-------------------------------------------------------------------------------
/* Clasificar el stock en categorías(incluir una columna calculada por cada):
 - ALTO si stock > 100
 - MEDIO si stock entre 50 y 100
 - BAJO si stock < 50 */
select i.id,
       p.nombre as producto,
       a.ubicacion,
       i.stock,
       case 
         when i.stock > 100 then 'ALTO'
         when i.stock between 50 and 100 then 'MEDIO'
         else 'BAJO'
       end as clasificacion
from inventario i
inner join producto p on p.id = i.id_producto
inner join almacen a on a.id = i.id_almacen;
-------------------------------------------------------------------------------
/* TRIGGER BEFORE INSERT: Si no se especifica valor de fecha actualizacion del 
 stock que lo establezca a la fecha actual. */
 
create or replace function auto_rellenar_fecha() 
returns trigger as $$  
begin
  -- Validar si hay suficiente stock
	if new.fecha is null then
    	new.fecha := now();
	end if;
	return new;
end;
$$ 
language plpgsql;

create or replace trigger fecha_no_especificada
before insert on inventario
for each row
execute function
	auto_rellenar_fecha();
-------------------------------------------------------------------------------
/* TRIGGER AFTER UPDATE: inserta un registro en una tabla “Alerta_Inventario” 
cuando el stock cruza por debajo de 10 unidades. */
create or replace function actualizar_fecha_stock()
returns trigger as $$
begin
  if new.stock is distinct from old.stock then
    new.fecha := now();
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trigger_actualizar_fecha
before update on inventario
for each row
execute function actualizar_fecha_stock();
-------------------------------------------------------------------------------
-------Funciones auxiliares para probar la funcionalidad de las queries--------
create or replace function ingresar_alerta_de_inventario() 
returns trigger as $$
begin
  if new.stock < 10 then	
      insert into alerta_inventario(id_inventario, fecha_actualizacion,stock_alerta) 
      values (new.id, now(),new.stock);
  end if;
  return new;
end;
$$ language plpgsql;

create or replace trigger inventario_en_alerta
after update on inventario
for each row
execute function
	ingresar_alerta_de_inventario(); 
-------------------------------------------------------------------------------
create or replace function obtener_id_Aleatorio_Producto()
returns integer as $$
declare
idRandom integer = 0;
begin 
	select id into idRandom from producto
	order by random()
	limit 1;
	return idRandom;
end;
$$ language plpgsql;
-------------------------------------------------------------------------------

create or replace function obtener_id_aleatorio_almacen()
returns integer as $$
declare
idRandom integer = 0;
begin 
	select id into idRandom from almacen
	order by random()
	limit 1;
	return idRandom;
end;
$$ language plpgsql;
-------------------------------------------------------------------------------
-- Funcion para rellenar datos del inventario 
---- cantidad: numero de registros que seran insertados en la tabla inventario
create or replace function rellenar_inventario(cantidad int)
returns table(id integer,id_producto integer, id_almacen integer, stock integer, fecha timestamp) as $$
begin
	insert into inventario (id_producto, id_almacen, stock, fecha)
	select 
	obtener_id_aleatorio_producto(),
	obtener_id_aleatorio_almacen(),
	(100+  random()*900)::int,
	'2024-01-01'::date + (random()*999)::int * interval '1 day'
	from generate_series(1,cantidad) as i;
	return query 
	select * from inventario
	order by 1 desc;
end;
$$ language plpgsql;
-------------------------------------------------------------------------------
--Funcion para testar el primer trigger
create or replace function rellenar_inventario_fechaActual(cantidad int)
returns table(id integer,id_producto integer, id_almacen integer, stock integer, fecha timestamp) as $$
begin
	insert into inventario (id_producto, id_almacen, stock)
	select 
	obtener_id_aleatorio_producto(),
	obtener_id_aleatorio_almacen(),
	(100+  random()*900)::int
	from generate_series(1,cantidad) as i;
	return query 
	select * from inventario
	order by 1 desc;
end;
$$ language plpgsql;
-------------------------------------------------------------------------------
-- Funcion para invocar el segundo trigger
create or replace function invocar_alerta_inventario()
returns setof alerta_inventario as $$
begin
	update inventario
	set stock = (random()*9)::int where id >0;
	return query
	select * from alerta_inventario i;
	
end;
$$ language plpgsql;
-------------------------------------------------------------------------------
-- Funcion para eliminar los registros en inventario
create or replace function limpiar_registros_inventario()
returns table(id_inventario integer,id_alerta_inventario integer) as $$
begin 

	truncate table alerta_inventario;
	alter sequence alerta_inventario_id_alerta_seq restart with 1;
	
	delete from inventario where id > 0;
	alter sequence inventario_id_seq restart with 1;
	
	return query
	select id,id_alerta from inventario i
	left join alerta_inventario ai on i.id = ai.id_inventario;
	
end;
$$ language plpgsql;
-------------------------------------------------------------------------------

select * from limpiar_registros_inventario();
select * from invocar_alerta_inventario();
select * from rellenar_inventario_fechaActual(10000);
select * from rellenar_inventario(1000);


drop function invocar_alerta_inventario();
drop function limpiar_registros_inventario();
drop function if exists obtener_id_aleatorio_producto();
drop function if exists obtener_id_aleatorio_almacen();
drop function if exists rellenar_inventario(cantidad int);
drop trigger if exists actualizar_fecha_stock on inventario;
drop trigger if exists inventario_en_alerta on inventario;
drop trigger if exists fecha_no_especificada on inventario;
drop table if exists producto cascade;
drop table if exists proveedor cascade;
drop table if exists inventario cascade;
drop table if exists almacen cascade;
drop table if exists alerta_inventario cascade;





		

