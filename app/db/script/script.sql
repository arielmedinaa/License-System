CREATE TABLE entrada_stock_detalle (
    entrada_id INTEGER NOT NULL,
    linea INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    codigo_producto TEXT NOT NULL,
    deposito_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    costo NUMERIC NOT NULL,
    costome NUMERIC DEFAULT 0,
    total NUMERIC,
    totalme NUMERIC,
    PRIMARY KEY (linea)
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

CREATE TABLE movcaja (
    id BIGSERIAL PRIMARY KEY,
    id_caja BIGINT NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo_movimiento VARCHAR(20) NOT NULL DEFAULT 'ABIERTO',
    monto NUMERIC(18,2) DEFAULT 0,
    observacion TEXT,
    
    CONSTRAINT fk_movcaja_caja
        FOREIGN KEY (id_caja)
        REFERENCES caja(id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_movcaja_id_caja ON movcaja(id_caja);
CREATE INDEX idx_movcaja_fecha ON movcaja(fecha);
CREATE INDEX idx_movcaja_tipo ON movcaja(tipo_movimiento);


CREATE TABLE transportistas (
    id SERIAL,
    nombre text NOT NULL,
    direccion text,
    mail text,
    tipcont integer NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE transferenciadepDetalle (
    id INTEGER,
    producto_id integer NOT NULL,
    producto_codigo text NOT NULL,
    linea integer NOT NULL,
    ori_deposito integer NOT NULL,
    destino_deposito integer NOT NULL,
    PRIMARY KEY (linea)
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
    id INTEGER,
    nameImg text NOT NULL UNIQUE,
    id_producto integer NOT NULL,
    principal boolean NOT NULL UNIQUE,
    url varchar,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL
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
    nombreCategoria text NOT NULL UNIQUE,
    codigoCategoria text UNIQUE,
    fechaCreacion timestamp NOT NULL,
    activo boolean NOT NULL default true,
    subcategoriaId integer NOT NULL default 0,
    PRIMARY KEY (id)
);

CREATE TABLE precios (
    id INTEGER NOT NULL,
    linea INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    precio INTEGER NOT NULL,
    activo BOOLEAN NOT NULL,
    iva BIGINT NOT NULL,
    tipo_precio VARCHAR,
    moneda TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL,
    PRIMARY KEY (id, linea)
);

CREATE UNIQUE INDEX unico_precio_activo_por_producto_id
ON precios (producto_id)
WHERE activo = true;

CREATE TABLE transferenciasDepositos (
    id SERIAL,
    numero integer NOT NULL,
    observacion text,
    fecha_creacion timestamp NOT NULL,
    fecha_modificacion timestamp NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE stock (
    id integer not null,
    origen text NOT NULL,
    linea integer NOT NULL,
    producto_id integer NOT NULL,
    codigo_producto text NOT NULL,
    cantidad integer NOT NULL,
    costo integer NOT NULL,
    costome decimal NOT NULL,
    total integer,
    totalme double precision,
    moneda text NOT NULL,
    fecha_creacion timestamp NOT NULL,
    deposito_id integer NOT NULL,
    PRIMARY KEY (linea, origen)
);

CREATE TABLE entrada_stock (
    id SERIAL PRIMARY KEY,
    sucursal_id INTEGER NOT NULL,
    numero_entrada INTEGER NOT NULL,
    moneda TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_modificacion TIMESTAMP NOT NULL DEFAULT NOW(),
    cotizacion NUMERIC,
    estado TEXT NOT NULL DEFAULT 'ACTIVO',
    anulada BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE factura (
    id BIGSERIAL PRIMARY KEY,

    -- Cliente / Proveedor
    cliente_id INTEGER NOT NULL REFERENCES clienteproveedor(id),

    -- Identificación principal
    numero TEXT NOT NULL,               -- Número de factura
    documento TEXT DEFAULT '' NOT NULL,                     -- Nro. documento IF o identificador extra
    timbrado TEXT DEFAULT '' NOT NULL,                      -- Timbrado vigente
    condicion TEXT DEFAULT '' NOT NULL,                     -- Contado / Crédito
    sucursal INTEGER REFERENCES sucursales(id),

    -- Fechas
    fecha TIMESTAMP NOT NULL,
    fechavincu TIMESTAMP,

    -- Montos en moneda local
    gra10 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    gra5 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    exenta NUMERIC(18,2) DEFAULT 0 NOT NULL,
    total NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva10 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva5 NUMERIC(18,2) DEFAULT 0 NOT NULL,

    -- Montos en moneda extranjera
    moneda TEXT DEFAULT '' NOT NULL,
    cotizacion NUMERIC(18,4) DEFAULT 0 NOT NULL,
    gra10me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    gra5me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    exentame NUMERIC(18,2) DEFAULT 0 NOT NULL,
    totalme NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva10me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva5me NUMERIC(18,2) DEFAULT 0 NOT NULL,

    -- Caja y movimientos
    id_caja INTEGER REFERENCES caja(id),
    id_movcaja INTEGER REFERENCES movcaja(id),

    -- Estados
    anulado BOOLEAN DEFAULT false,
    estado TEXT,             -- Emitida / Pendiente / Cobrado / Vencido…
    migrado BOOLEAN DEFAULT false,

    -- Datos SIFEN / Electrónica
    cdc TEXT,                -- Código único electrónico
    lote TEXT,
    estsifen TEXT,
    digestvalue TEXT,

    -- Descuentos
    porcdesc NUMERIC(5,2) DEFAULT 0,
    descuento NUMERIC(18,2) DEFAULT 0,
    descuentome NUMERIC(18,2) DEFAULT 0,

    -- Relación con otras facturas
    cmpvincu TEXT DEFAULT '',
    timvincu TEXT DEFAULT '',
    cdcvincu TEXT DEFAULT '',
    motivovincu TEXT DEFAULT 'Devolucion',

    -- Exportación / aduanas
    nomeclatura TEXT DEFAULT '',
    resolucion TEXT DEFAULT '',
    detalleexpo TEXT DEFAULT '',
    tipoexpo TEXT DEFAULT '',
    paisorigen TEXT DEFAULT '',
    paisdestino TEXT DEFAULT '',

    -- Pedidos / Remisiones
    idpedido INTEGER DEFAULT 0,
    idremision INTEGER DEFAULT 0,

    -- Vendedor / otros
    vendedorid INTEGER,

    -- Créditos / Cuotas
    cuotainicial NUMERIC(18,2),
    cuotamensual NUMERIC(18,2),
    cuotadias INTEGER,
    cuotacant INTEGER,
    cuotaprimervenc DATE,
    cuotainicialme NUMERIC(18,2),

    -- Otros
    origen TEXT DEFAULT 'FV' NOT NULL,
    anticipo NUMERIC(18,2) DEFAULT 0,
    idsucursalcliente INTEGER DEFAULT 0
);

CREATE TABLE facturadetalle (
    id BIGSERIAL PRIMARY KEY,

    factura_id BIGINT NOT NULL 
        REFERENCES factura(id) ON DELETE CASCADE,

    producto_id INTEGER NOT NULL 
        REFERENCES productos(id),

    -- Datos del producto al momento de la venta (congelados)
    producto_codigo TEXT NOT NULL,
    producto_nombre TEXT NOT NULL,
    unidad_medida TEXT,
    
    -- Cantidad y precios
    cantidad NUMERIC(18,2) NOT NULL,
    precio NUMERIC(18,2) NOT NULL,
    precio_me NUMERIC(18,2),

    -- IVA por línea
    iva_tipo INTEGER NOT NULL,
    iva_monto NUMERIC(18,2) NOT NULL,
    iva_monto_me NUMERIC(18,2),

    gra10 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    gra5 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    exenta NUMERIC(18,2) DEFAULT 0 NOT NULL,
    total NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva10 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva5 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    gra10me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    gra5me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    exentame NUMERIC(18,2) DEFAULT 0 NOT NULL,
    totalme NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva10me NUMERIC(18,2) DEFAULT 0 NOT NULL,
    iva5me NUMERIC(18,2) DEFAULT 0 NOT NULL,

    -- Descuentos por línea
    descuento NUMERIC(18,2) DEFAULT 0,
    descuentome NUMERIC(18,2) DEFAULT 0,

    deposito_id INTEGER REFERENCES depositos(id),

    -- Orden dentro de la factura
    linea INTEGER NOT NULL
);

CREATE INDEX idx_facturadetalle_factura ON facturadetalle(factura_id);
CREATE INDEX idx_facturadetalle_producto ON facturadetalle(producto_id);
CREATE INDEX idx_facturadetalle_linea ON facturadetalle(factura_id, linea);

CREATE TABLE factura_compra (
    id BIGSERIAL PRIMARY KEY,
    proveedor_id INTEGER NOT NULL REFERENCES clienteproveedor(id),
    numero VARCHAR(50) NOT NULL,
    timbrado VARCHAR(20),
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    moneda TEXT NOT NULL,
    cotizacion NUMERIC(15,4),
    total NUMERIC(15,2) DEFAULT 0,
    total_me NUMERIC(15,2) DEFAULT 0,
    estado VARCHAR(20) DEFAULT 'PENDIENTE',
    anulada BOOLEAN NOT NULL DEFAULT false,
    observacion TEXT,
    deposito_id INTEGER NOT NULL REFERENCES depositos(id)
);

CREATE TABLE factura_compra_detalle (
    id BIGSERIAL PRIMARY KEY,
    factura_id BIGINT NOT NULL REFERENCES factura_compra(id) ON DELETE CASCADE,
    linea INTEGER NOT NULL,
    producto_id INTEGER NOT NULL REFERENCES productos(id),
    producto_codigo TEXT NOT NULL,
    cantidad NUMERIC(15,2) NOT NULL,
    costo NUMERIC(15,2) NOT NULL,
    costome NUMERIC(15,2),
    total NUMERIC(15,2) NOT NULL,
    totalme NUMERIC(15,2),
    moneda TEXT NOT NULL,
    deposito_id INTEGER NOT NULL REFERENCES depositos(id)
);

CREATE INDEX idx_factura_compra_proveedor
ON factura_compra (proveedor_id);

CREATE UNIQUE INDEX idx_factura_compra_numero
ON factura_compra (numero);

CREATE INDEX idx_factura_compra_fecha
ON factura_compra (fecha);

CREATE INDEX idx_factura_compra_detalle_factura
ON factura_compra_detalle (factura_id);

CREATE INDEX idx_factura_compra_detalle_producto
ON factura_compra_detalle (producto_id);


ALTER TABLE caja
ADD CONSTRAINT fk_caja_id_deposito_depositos_id 
FOREIGN KEY(id_deposito) REFERENCES depositos(id) ON DELETE CASCADE;

ALTER TABLE caja
ADD CONSTRAINT fk_caja_id_sucursal_sucursales_id 
FOREIGN KEY(id_sucursal) REFERENCES sucursales(id) ON DELETE CASCADE;

ALTER TABLE chofer
ADD CONSTRAINT fk_chofer_id_transportista_transportistas_id 
FOREIGN KEY(id_transportista) REFERENCES transportistas(id) ON DELETE CASCADE;

ALTER TABLE entrada_stock
ADD CONSTRAINT fk_entrada_stock_sucursal
FOREIGN KEY (sucursal_id) REFERENCES sucursales(id) ON DELETE CASCADE;

ALTER TABLE entrada_stock_detalle
ADD CONSTRAINT fk_detalle_entrada
FOREIGN KEY (entrada_id) REFERENCES entrada_stock(id) ON DELETE CASCADE;

ALTER TABLE entrada_stock_detalle
ADD CONSTRAINT fk_detalle_producto
FOREIGN KEY (producto_id) REFERENCES productos(id);

ALTER TABLE entrada_stock_detalle
ADD CONSTRAINT fk_detalle_deposito
FOREIGN KEY (deposito_id) REFERENCES depositos(id);

ALTER TABLE productos
ADD CONSTRAINT fk_productos_categoria_id_categorias_id 
FOREIGN KEY(categoria_id) REFERENCES categorias(id) ON DELETE CASCADE;

ALTER TABLE stock
ADD CONSTRAINT fk_stock_deposito_id_depositos_id 
FOREIGN KEY(deposito_id) REFERENCES depositos(id) ON DELETE CASCADE;

ALTER TABLE stock
ADD CONSTRAINT fk_stock_producto_id_productos_id 
FOREIGN KEY(producto_id) REFERENCES productos(id) ON DELETE CASCADE;

ALTER TABLE vehiculo
ADD CONSTRAINT fk_vehiculo_id_transportista_transportistas_id 
FOREIGN KEY(id_transportista) REFERENCES transportistas(id) ON DELETE CASCADE;

ALTER TABLE transferenciadepDetalle
ADD CONSTRAINT fk_transferenciadepDetalle_producto_id_productos_id 
FOREIGN KEY(producto_id) REFERENCES productos(id) ON DELETE CASCADE;

ALTER TABLE entrada_stock_detalle DROP CONSTRAINT entrada_stock_detalle_pkey;

ALTER TABLE entrada_stock_detalle
    ADD CONSTRAINT entrada_stock_detalle_pkey
    PRIMARY KEY (entrada_id, linea);

ALTER TABLE stock DROP CONSTRAINT stock_pkey;

ALTER TABLE stock
ADD PRIMARY KEY (id, origen, linea);

ALTER TABLE transferenciadepDetalle DROP CONSTRAINT transferenciadepdetalle_pkey;

ALTER TABLE transferenciadepDetalle
ADD PRIMARY KEY (id, linea);

--TRIGGERS
CREATE OR REPLACE FUNCTION verificar_uso_cliente()
RETURNS trigger AS $$
DECLARE
    proveedor_usado INT;
    facturas_usado INT;
    caja_usado INT;
BEGIN
    SELECT COUNT(*) INTO proveedor_usado
    FROM productos
    WHERE proveedor = OLD.ruc;

    IF proveedor_usado > 0 THEN
        RAISE EXCEPTION
            'No se puede eliminar el cliente con RUC %, porque está siendo utilizado en productos.',
            OLD.ruc;
    END IF;
    SELECT COUNT(*) INTO facturas_usado
    FROM factura
    WHERE ruc_cliente = OLD.ruc;

    IF facturas_usado > 0 THEN
        RAISE EXCEPTION
            'No se puede eliminar el cliente con RUC %, porque está siendo utilizado en facturas.',
            OLD.ruc;
    END IF;
    SELECT COUNT(*) INTO caja_usado
    FROM movcaja
    WHERE ruc = OLD.ruc;

    IF caja_usado > 0 THEN
        RAISE EXCEPTION
            'No se puede eliminar el cliente con RUC %, porque está siendo utilizado en caja.',
            OLD.ruc;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificar_uso_producto()
RETURNS trigger AS $$
DECLARE
    usado INT;
BEGIN
    SELECT COUNT(*) INTO usado
    FROM facturadetalle
    WHERE producto_id = OLD.id;

    IF usado > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el producto %, está usado en facturas.', OLD.id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_uso_producto
BEFORE DELETE ON productos
FOR EACH ROW
EXECUTE FUNCTION verificar_uso_producto();

CREATE OR REPLACE FUNCTION insertar_stock_factura()
RETURNS trigger AS $$
BEGIN
    INSERT INTO stock (
        id,
        origen,
        linea,
        producto_id,
        codigo_producto,
        cantidad,
        costo,
        costome,
        total,
        totalme,
        moneda,
        fecha_creacion,
        deposito_id
    ) VALUES (
        NEW.id,
        'FV',                      -- origen fijo FACTURA VENTA
        NEW.linea,                 -- la misma línea del detalle
        NEW.producto_id,
        NEW.producto_codigo,
        (NEW.cantidad * -1),       -- salida
        0,                         -- costo = 0
        0,                         -- costome = 0
        NEW.total,
        NEW.total_me,
        NEW.moneda,
        NOW(),
        NEW.deposito_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insertar_stock_factura
AFTER INSERT ON facturadetalle
FOR EACH ROW
EXECUTE FUNCTION insertar_stock_factura();

CREATE OR REPLACE FUNCTION insertar_stock_compra()
RETURNS trigger AS $$
BEGIN
    INSERT INTO stock (
        id,
        origen,
        linea,
        producto_id,
        codigo_producto,
        cantidad,
        costo,
        costome,
        total,
        totalme,
        moneda,
        fecha_creacion,
        deposito_id
    ) VALUES (
        NEW.factura_id,    -- id de la compra
        'FC',
        NEW.linea,
        NEW.producto_id,
        NEW.producto_codigo,
        NEW.cantidad,      -- entrada: cantidad positiva
        NEW.costo,
        COALESCE(NEW.costome,0),
        NEW.total,
        NEW.totalme,
        NEW.moneda,
        NOW(),
        NEW.deposito_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insertar_stock_compra
AFTER INSERT ON factura_compra_detalle
FOR EACH ROW
EXECUTE FUNCTION insertar_stock_compra();

CREATE OR REPLACE FUNCTION revertir_stock_venta()
RETURNS trigger AS $$
BEGIN
    IF NEW.estado = 'ANULADA' AND OLD.estado <> 'ANULADA' THEN
        DELETE FROM stock
        WHERE origen = 'FV'
          AND id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_revertir_stock_venta
AFTER UPDATE ON factura
FOR EACH ROW
WHEN (OLD.estado IS DISTINCT FROM NEW.estado)
EXECUTE FUNCTION revertir_stock_venta();

CREATE OR REPLACE FUNCTION revertir_stock_compra()
RETURNS trigger AS $$
BEGIN
    IF NEW.estado = 'ANULADA' AND OLD.estado <> 'ANULADA' THEN
        DELETE FROM stock
        WHERE origen = 'FC'
          AND id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_revertir_stock_compra
AFTER UPDATE ON factura_compra
FOR EACH ROW
WHEN (OLD.estado IS DISTINCT FROM NEW.estado)
EXECUTE FUNCTION revertir_stock_compra();

CREATE OR REPLACE FUNCTION insertar_stock_entrada()
RETURNS trigger AS $$
BEGIN
    INSERT INTO stock (
        id,
        origen,
        linea,
        producto_id,
        codigo_producto,
        cantidad,
        costo,
        costome,
        total,
        totalme,
        moneda,
        fecha_creacion,
        deposito_id
    )
    VALUES (
        NEW.entrada_id,        -- id de la entrada
        'ES',                  -- Entrada de Stock
        NEW.linea,
        NEW.producto_id,
        NEW.codigo_producto,
        NEW.cantidad,          -- entrada = positivo
        NEW.costo,
        NEW.costome,
        NEW.total,
        NEW.totalme,
        (SELECT moneda FROM entrada_stock WHERE id = NEW.entrada_id),
        NOW(),
        NEW.deposito_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_insertar_stock_entrada
AFTER INSERT ON entrada_stock_detalle
FOR EACH ROW
EXECUTE FUNCTION insertar_stock_entrada();


INSERT INTO sucursales (nombre, codigo, direccion, fecha_creacion, fecha_modificacion) VALUES
('Sucursal Central', 'SUC-001', 'Av. Principal 123', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Sucursal Norte', 'SUC-002', 'Calle Norte 456', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Sucursal Sur', 'SUC-003', 'Calle Sur 789', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO depositos (codigo, nombre_deposito, direccion_deposito, telefono, fecha_creacion) VALUES
(101, 'Depósito Principal', 'Zona Industrial A-12', '021-555-1000', CURRENT_TIMESTAMP),
(102, 'Depósito Secundario', 'Zona Industrial B-34', '021-555-2000', CURRENT_TIMESTAMP),
(103, 'Depósito Auxiliar', 'Zona Industrial C-56', '021-555-3000', CURRENT_TIMESTAMP);

INSERT INTO categorias (nombreCategoria, codigoCategoria, activo, fechaCreacion) VALUES
('Electrónicos', 'CAT-E', true, CURRENT_TIMESTAMP),
('Hogar', 'CAT-H', true, CURRENT_TIMESTAMP),
('Oficina', 'CAT-O', true, CURRENT_TIMESTAMP);
