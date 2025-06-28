CREATE TABLE proveedor (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  telefono TEXT NOT NULL
);

CREATE TABLE producto (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  id_proveedor INT NOT NULL,  -- Added column definition
  FOREIGN KEY (id_proveedor) REFERENCES proveedor(id)
);

CREATE TABLE almacen (
  id SERIAL PRIMARY KEY,
  ubicacion TEXT NOT NULL
);

CREATE TABLE inventario (
  id SERIAL PRIMARY KEY,
  id_producto INT NOT NULL,   -- Added column definition
  id_almacen INT NOT NULL,    -- Added column definition
  stock INT NOT NULL,
  fecha TIMESTAMP,
  FOREIGN KEY (id_producto) REFERENCES producto(id),
  FOREIGN KEY (id_almacen) REFERENCES almacen(id)
);

CREATE TABLE alerta_inventario (
  id_alerta SERIAL PRIMARY KEY,  -- Added PRIMARY KEY
  id_inventario INT NOT NULL,     -- Added column definition
  stock_alerta INT,
  fecha_actualizacion TIMESTAMP,
  FOREIGN KEY (id_inventario) REFERENCES inventario(id)
);

CREATE TABLE proveedor (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  telefono TEXT NOT NULL
);

CREATE TABLE producto (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  id_proveedor INT NOT NULL,  -- Added column definition
  FOREIGN KEY (id_proveedor) REFERENCES proveedor(id)
);

CREATE TABLE almacen (
  id SERIAL PRIMARY KEY,
  ubicacion TEXT NOT NULL
);

CREATE TABLE inventario (
  id SERIAL PRIMARY KEY,
  id_producto INT NOT NULL,   -- Added column definition
  id_almacen INT NOT NULL,    -- Added column definition
  stock INT NOT NULL,
  fecha TIMESTAMP,
  FOREIGN KEY (id_producto) REFERENCES producto(id),
  FOREIGN KEY (id_almacen) REFERENCES almacen(id)
);

CREATE TABLE alerta_inventario (
  id_alerta SERIAL PRIMARY KEY,  -- Added PRIMARY KEY
  id_inventario INT NOT NULL,     -- Added column definition
  stock_alerta INT,
  fecha_actualizacion TIMESTAMP,
  FOREIGN KEY (id_inventario) REFERENCES inventario(id)
);

-- INSERT SAMPLE DATA

-- Insert suppliers
INSERT INTO proveedor (nombre, telefono) VALUES
('Proveedor ABC S.A.', '+56-2-1234-5678'),
('Distribuidora XYZ Ltda.', '+56-9-8765-4321'),
('Comercial DEF SpA', '+56-2-9876-5432'),
('Importadora GHI S.A.', '+56-9-1357-2468');

-- Insert warehouses
INSERT INTO almacen (ubicacion) VALUES
('Bodega Central - Santiago'),
('Bodega Norte - Antofagasta'),
('Bodega Sur - Concepción'),
('Bodega Oeste - Valparaíso');

-- Insert products
INSERT INTO producto (nombre, id_proveedor) VALUES
('Laptop Dell Inspiron 15', 1),
('Mouse Inalámbrico Logitech', 1),
('Teclado Mecánico Corsair', 2),
('Monitor Samsung 24"', 2),
('Impresora HP LaserJet', 3),
('Disco Duro Externo 1TB', 3),
('Webcam HD Logitech', 1),
('Audífonos Sony WH-1000XM4', 4),
('Tablet iPad Air', 4),
('Cable HDMI 2m', 2);

-- Insert inventory
INSERT INTO inventario (id_producto, id_almacen, stock, fecha) VALUES
(1, 1, 25, '2024-12-01 10:00:00'),
(1, 2, 15, '2024-12-01 10:00:00'),
(2, 1, 100, '2024-12-01 10:30:00'),
(2, 3, 75, '2024-12-01 10:30:00'),
(3, 1, 50, '2024-12-01 11:00:00'),
(4, 2, 20, '2024-12-01 11:30:00'),
(4, 4, 18, '2024-12-01 11:30:00'),
(5, 1, 8, '2024-12-01 12:00:00'),
(6, 3, 45, '2024-12-01 12:30:00'),
(7, 1, 30, '2024-12-01 13:00:00'),
(8, 4, 12, '2024-12-01 13:30:00'),
(9, 1, 6, '2024-12-01 14:00:00'),
(10, 2, 200, '2024-12-01 14:30:00');

-- Insert inventory alerts (for low stock items)
INSERT INTO alerta_inventario (id_inventario, stock_alerta, fecha_actualizacion) VALUES
(8, 10, '2024-12-01 15:00:00'),  -- HP LaserJet low stock
(12, 10, '2024-12-01 15:30:00'), -- iPad Air low stock
(11, 15, '2024-12-01 16:00:00'); -- Sony Headphones low stock
