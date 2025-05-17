-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS vertel;
USE vertel;

-- Tabla de Proveedores
CREATE TABLE Proveedores (
    id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100)
);

-- Tabla de Artículos (Inventario)
CREATE TABLE Articulos (
    id_articulo INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

-- Tabla de Clientes (por categoría)
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) CHECK (categoria IN ('Minorista', 'Mayorista', 'Corporativo')),
    contacto VARCHAR(100)
);

-- Tabla de Ventas
CREATE TABLE Ventas (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    fecha DATE NOT NULL,
    metodo_pago VARCHAR(50) CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia')),
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Tabla de Detalle de Ventas
CREATE TABLE DetalleVenta (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_venta INT,
    id_articulo INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_articulo) REFERENCES Articulos(id_articulo)
);

-- Tabla de Compras a Proveedores
CREATE TABLE ComprasProveedores (
    id_compra INT PRIMARY KEY AUTO_INCREMENT,
    id_proveedor INT,
    fecha DATE NOT NULL,
    monto_total DECIMAL(10,2),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

-- Tabla de Detalle de Compras
CREATE TABLE DetalleCompra (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_compra INT,
    id_articulo INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_compra) REFERENCES ComprasProveedores(id_compra),
    FOREIGN KEY (id_articulo) REFERENCES Articulos(id_articulo)
);

-- Tabla de Pagos a Proveedores
CREATE TABLE PagosProveedores (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_compra INT UNIQUE,
    monto DECIMAL(10,2) NOT NULL,
    fecha_maxima DATE,
    FOREIGN KEY (id_compra) REFERENCES ComprasProveedores(id_compra)
);

-- Tabla de Empleados
CREATE TABLE Empleados (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    puesto VARCHAR(50),
    salario DECIMAL(10,2),
    fecha_contratacion DATE
);


-- Datos de Ejemplo (INSERT)

-- Proveedores
INSERT INTO Proveedores (nombre, contacto) VALUES 
('TecnoSuministros', 'contacto@tecnosuministros.com'),
('ElectroParts', 'info@electroparts.gt');

-- Artículos
INSERT INTO Articulos (descripcion, precio, stock, id_proveedor) VALUES 
('Teclado mecánico RGB', 250.00, 50, 1),
('Monitor 24" Full HD', 1200.00, 30, 2),
('Mouse inalámbrico', 180.00, 100, 1);

-- Clientes
INSERT INTO Clientes (nombre, categoria, contacto) VALUES 
('Tienda Tech', 'Minorista', 'tech@mail.com'),
('Empresa XYZ', 'Corporativo', 'compras@xyz.com');

-- Ventas
INSERT INTO Ventas (id_cliente, fecha, metodo_pago, total) VALUES 
(1, '2025-05-10', 'Tarjeta', 1450.00),
(2, '2025-05-12', 'Transferencia', 3600.00);

-- DetalleVenta
INSERT INTO DetalleVenta (id_venta, id_articulo, cantidad, precio_unitario) VALUES 
(1, 1, 2, 250.00),
(1, 3, 1, 180.00),
(2, 2, 3, 1200.00);

-- Compras a Proveedores
INSERT INTO ComprasProveedores (id_proveedor, fecha, monto_total) VALUES 
(1, '2025-04-15', 5000.00),
(2, '2025-04-20', 8000.00);

-- DetalleCompra
INSERT INTO DetalleCompra (id_compra, id_articulo, cantidad, precio_unitario) VALUES 
(1, 1, 100, 200.00),
(2, 2, 10, 1000.00);

-- Pagos a Proveedores
INSERT INTO PagosProveedores (id_compra, monto, fecha_maxima) VALUES 
(1, 5000.00, '2025-05-15'),
(2, 8000.00, '2025-05-20');

-- Empleados
INSERT INTO Empleados (nombre, puesto, salario, fecha_contratacion) VALUES 
('Juan Pérez', 'Vendedor', 5000.00, '2024-01-10'),
('María López', 'Gerente', 10000.00, '2023-06-15');


-- Consultas SQL (Requerimientos)

-- a. Control de inventario (Artículos con stock)
SELECT id_articulo, descripcion, stock FROM Articulos WHERE stock > 0;

-- b. Ventas filtradas por fecha, cliente o método de pago
-- Por fecha:
SELECT V.id_venta, C.nombre AS cliente, V.fecha, V.metodo_pago, V.total 
FROM Ventas V INNER JOIN Clientes C ON V.id_cliente = C.id_cliente
WHERE V.fecha BETWEEN '2025-05-01' AND '2025-05-15';

-- Por cliente:
SELECT V.id_venta, C.nombre AS cliente, V.fecha, V.total 
FROM Ventas V INNER JOIN Clientes C ON V.id_cliente = C.id_cliente
WHERE C.nombre LIKE '%Tech%';

-- Por método de pago:
SELECT id_venta, fecha, metodo_pago, total FROM Ventas 
WHERE metodo_pago = 'Tarjeta';

-- c. Clientes por categoría
SELECT nombre, categoria, contacto FROM Clientes 
WHERE categoria = 'Corporativo';

-- d. Compras a proveedores (filtros)
-- Por proveedor:
SELECT P.nombre AS proveedor, CP.fecha, CP.monto_total 
FROM ComprasProveedores CP INNER JOIN Proveedores P ON CP.id_proveedor = P.id_proveedor
WHERE P.id_proveedor = 1;

-- Por fecha:
SELECT P.nombre, CP.fecha, CP.monto_total 
FROM ComprasProveedores CP INNER JOIN Proveedores P ON CP.id_proveedor = P.id_proveedor
WHERE CP.fecha = '2025-04-15';

-- e. Artículos con proveedor
SELECT A.descripcion, A.precio, P.nombre AS proveedor 
FROM Articulos A INNER JOIN Proveedores P ON A.id_proveedor = P.id_proveedor;

-- f. Pagos pendientes a proveedores
SELECT PP.id_pago, P.nombre AS proveedor, PP.monto, PP.fecha_maxima 
FROM PagosProveedores PP INNER JOIN ComprasProveedores CP ON PP.id_compra = CP.id_compra
INNER JOIN Proveedores P ON CP.id_proveedor = P.id_proveedor
WHERE PP.fecha_maxima > CURDATE(); -- filtra los pagos cuya fecha máxima de pago sea posterior a la fecha actual, es decir, pagos que aún no vencen.

-- g. Listado de empleados con salario
SELECT nombre, puesto, salario FROM Empleados ORDER BY salario DESC;