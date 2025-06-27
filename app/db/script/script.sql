CREATE TABLE entradadetalle (
    id SERIAL,
    producto_id integer NOT NULL,
    codigo_producto text NOT NULL,
    deposito_id integer NOT NULL,
    linea integer NOT NULL,
    cantidad integer,
    costo integer,
    costome decimal,
    total integer,
    totalme decimal,
    PRIMARY KEY (id, linea)
);

CREATE TABLE caja (
    id SERIAL,
    id_deposito integer NOT NULL,
    id_sucursal integer NOT NULL,
    usuario_id integer NOT NULL,
    nombre text NOT NULL UNIQUE,
    activo boolean NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX caja_index_1
ON caja (id, id_deposito, id_sucursal, nombre, activo);

CREATE TABLE transportistas (
    id SERIAL,
    nombre text NOT NULL,
    direccion text,
    mail text,
    tipcont integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE transferenciadepDetalle (
    id SERIAL,
    producto_id integer NOT NULL,
    producto_codigo text NOT NULL,
    linea integer NOT NULL,
    ori_deposito integer NOT NULL,
    destino_deposito integer NOT NULL,
    PRIMARY KEY (id, linea)
);

CREATE TABLE vehiculo (
    id SERIAL,
    id_transportista integer NOT NULL,
    marca text NOT NULL,
    chapa varchar(8),
    tipo integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE sucursales (
    id SERIAL,
    nombre text NOT NULL,
    codigo text NOT NULL,
    direccion text,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE productos (
    id SERIAL,
    codigo text NOT NULL UNIQUE DEFAULT '',
    nombre text NOT NULL DEFAULT '',
    stock boolean NOT NULL DEFAULT true,
    descripcion text DEFAULT '',
    fecha_creacion timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizada timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unidad_medida varchar NOT NULL DEFAULT 'LT',
    categoria_id integer NOT NULL DEFAULT 0,
    proveedor text DEFAULT '',
    nomenclatura text DEFAULT '',
    PRIMARY KEY (id)
);

CREATE INDEX productos_index_products2
ON productos (codigo, nombre);

CREATE TABLE imagenesProductos (
    id SERIAL,
    nameImg text NOT NULL UNIQUE,
    id_producto integer NOT NULL,
    principal boolean NOT NULL UNIQUE,
    url varchar,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX imagenesProductos_index_1
ON imagenesProductos (id, nameImg);

CREATE TABLE depositos (
    id SERIAL,
    codigo integer UNIQUE,
    nombre_deposito text NOT NULL,
    direccion_deposito text NOT NULL,
    telefono text NOT NULL,
    fecha_creacion timestamp,
    PRIMARY KEY (id)
);

CREATE TABLE chofer (
    id SERIAL,
    id_transportista integer NOT NULL,
    nombre text NOT NULL,
    documento text NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE clienteproveedor (
    id SERIAL,
    ruc text NOT NULL,
    nombre text NOT NULL,
    mail varchar NOT NULL,
    telefono varchar,
    tipo text,
    direccion text,
    natrec varchar,
    tipope integer,
    tipcont integer,
    tipdoc integer,
    numerodoc text,
    ciuemidesc varchar,
    paisemidesc varchar,
    paisemi varchar,
    nroconstancia varchar,
    nrocontrol varchar,
    PRIMARY KEY (id)
);

CREATE TABLE categorias (
    id SERIAL,
    nombre_categoria text NOT NULL UNIQUE,
    codigo_categoria text UNIQUE,
    fecha_creacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE precios (
    id SERIAL,
    producto_id integer NOT NULL,
    precio integer NOT NULL,
    activo boolean NOT NULL,
    iva bigint NOT NULL,
    tipo_precio varchar,
    moneda text NOT NULL,
    fecha_creacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE transferenciasDepositos (
    id SERIAL,
    numero integer NOT NULL,
    observacion text,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE stock (
    id SERIAL,
    origen text NOT NULL,
    linea integer NOT NULL,
    producto_id integer NOT NULL,
    codigo_producto text NOT NULL,
    cantidad integer NOT NULL,
    costo_entrada integer NOT NULL,
    costome_entrada decimal NOT NULL,
    totalLocal integer,
    totalMe decimal,
    moneda text NOT NULL,
    fecha_creacion timestamp NOT NULL,
    deposito_id integer NOT NULL,
    PRIMARY KEY (id, linea, origen)
);

CREATE TABLE entradaStock (
    id SERIAL,
    sucursal_id integer NOT NULL,
    numero_entrada integer NOT NULL,
    moneda text NOT NULL,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL,
    cotizacion numeric,
    PRIMARY KEY (id)
);

ALTER TABLE caja
ADD CONSTRAINT fk_caja_id_deposito_depositos_id FOREIGN KEY(id_deposito) REFERENCES depositos(id);

ALTER TABLE caja
ADD CONSTRAINT fk_caja_id_sucursal_sucursales_id FOREIGN KEY(id_sucursal) REFERENCES sucursales(id);

ALTER TABLE chofer
ADD CONSTRAINT fk_chofer_id_transportista_transportistas_id FOREIGN KEY(id_transportista) REFERENCES transportistas(id);

ALTER TABLE entradadetalle
ADD CONSTRAINT fk_entradadetalle_deposito_id_depositos_id FOREIGN KEY(deposito_id) REFERENCES depositos(id);

ALTER TABLE entradadetalle
ADD CONSTRAINT fk_entradadetalle_producto_id_productos_id FOREIGN KEY(producto_id) REFERENCES productos(id);

ALTER TABLE entradaStock
ADD CONSTRAINT fk_entradaStock_sucursal_id_sucursales_id FOREIGN KEY(sucursal_id) REFERENCES sucursales(id);

ALTER TABLE productos
ADD CONSTRAINT fk_productos_categoria_id_categorias_id FOREIGN KEY(categoria_id) REFERENCES categorias(id);

ALTER TABLE stock
ADD CONSTRAINT fk_stock_deposito_id_depositos_id FOREIGN KEY(deposito_id) REFERENCES depositos(id);

ALTER TABLE stock
ADD CONSTRAINT fk_stock_producto_id_productos_id FOREIGN KEY(producto_id) REFERENCES productos(id);

ALTER TABLE vehiculo
ADD CONSTRAINT fk_vehiculo_id_transportista_transportistas_id FOREIGN KEY(id_transportista) REFERENCES transportistas(id);

ALTER TABLE transferenciadepDetalle
ADD CONSTRAINT fk_transferenciadepDetalle_producto_id_productos_id FOREIGN KEY(producto_id) REFERENCES productos(id);

CREATE OR REPLACE FUNCTION verificar_uso_cliente()
RETURNS trigger AS $$
DECLARE
    proveedor_usado INT;
BEGIN
    SELECT COUNT(*) INTO proveedor_usado
    FROM productos
    WHERE proveedor = OLD.ruc;

    IF proveedor_usado > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el cliente con RUC %, porque está siendo utilizado en productos.', OLD.ruc;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


INSERT INTO sucursales (nombre, codigo, direccion, fecha_creacion, fecha_modificacion) VALUES
('Sucursal Central', 'SUC-001', 'Av. Principal 123', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Sucursal Norte', 'SUC-002', 'Calle Norte 456', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Sucursal Sur', 'SUC-003', 'Calle Sur 789', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO depositos (codigo, nombre_deposito, direccion_deposito, telefono, fecha_creacion) VALUES
(101, 'Depósito Principal', 'Zona Industrial A-12', '021-555-1000', CURRENT_TIMESTAMP),
(102, 'Depósito Secundario', 'Zona Industrial B-34', '021-555-2000', CURRENT_TIMESTAMP),
(103, 'Depósito Auxiliar', 'Zona Industrial C-56', '021-555-3000', CURRENT_TIMESTAMP);

INSERT INTO categorias (nombre_categoria, codigo_categoria, fecha_creacion) VALUES
('Electrónicos', 'CAT-E', CURRENT_TIMESTAMP),
('Hogar', 'CAT-H', CURRENT_TIMESTAMP),
('Oficina', 'CAT-O', CURRENT_TIMESTAMP);