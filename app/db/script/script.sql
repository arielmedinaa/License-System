

CREATE TABLE "entradadetalle" (
    "id" integer NOT NULL,
    "producto_id" integer NOT NULL,
    "codigo_producto" text NOT NULL,
    "deposito_id" integer NOT NULL,
    "linea" integer NOT NULL,
    "cantidad" integer,
    "costo" integer,
    "costome" decimal,
    "total" integer,
    "totalme" decimal,
    PRIMARY KEY ("id", "linea")
);



CREATE TABLE "caja" (
    "id" integer NOT NULL,
    "id_deposito" integer NOT NULL,
    "id_sucursal" integer NOT NULL,
    "usuario_id" integer NOT NULL,
    "nombre" text NOT NULL UNIQUE,
    "activo" boolean NOT NULL,
    PRIMARY KEY ("id")
);


CREATE INDEX "caja_index_1"
ON "caja" ("id", "id_deposito", "id_sucursal", "nombre", "activo");


CREATE TABLE "transportistas" (
    "id" integer NOT NULL,
    "nombre" text NOT NULL,
    "direccion" text,
    "mail" text,
    "tipcont" integer NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "transferenciadepDetalle" (
    "id" integer NOT NULL,
    "producto_id" integer NOT NULL,
    "producto_codigo" text NOT NULL,
    "linea" integer NOT NULL,
    "ori_deposito" integer NOT NULL,
    "destino_deposito" integer NOT NULL,
    PRIMARY KEY ("id", "linea")
);



CREATE TABLE "vehiculo" (
    "id" integer NOT NULL,
    "id_transportista" integer NOT NULL,
    "marca" text NOT NULL,
    "chapa" varchar(8),
    "tipo" integer NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "sucursales" (
    "id" integer NOT NULL,
    "nombre" text NOT NULL,
    "codigo" text NOT NULL,
    "direccion" text,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_modificacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "productos" (
    "id" integer NOT NULL,
    "codigo" text NOT NULL UNIQUE,
    "nombre" bigint NOT NULL,
    "stock" boolean NOT NULL,
    "descripcion" text,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_actualizada" timestamp NOT NULL,
    "unidad_medida" varchar NOT NULL,
    "categoria_id" integer NOT NULL UNIQUE,
    "proveedor" text,
    "nomenclatura" text,
    PRIMARY KEY ("id")
);



CREATE TABLE "imagenesProductos" (
    "id" integer NOT NULL,
    "nameImg" text NOT NULL UNIQUE,
    "id_producto" integer NOT NULL,
    "principal" boolean NOT NULL UNIQUE,
    "url" varchar,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_modificacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);


CREATE INDEX "imagenesProductos_index_1"
ON "imagenesProductos" ("id", "nameImg");


CREATE TABLE "depositos" (
    "id" integer NOT NULL,
    "codigo" integer UNIQUE,
    "nombre_deposito" text NOT NULL,
    "direccion_deposito" text NOT NULL,
    "telefono" text NOT NULL,
    "fecha_creacion" timestamp,
    PRIMARY KEY ("id")
);



CREATE TABLE "clienteproveedor" (
    "id" integer NOT NULL,
    "ruc" text NOT NULL,
    "nombre" text NOT NULL,
    "mail" varchar NOT NULL,
    "telefono" varchar,
    "tipo" text,
    "direccion" text,
    "natrec" varchar,
    "tipope" integer,
    "tipcont" integer,
    "tipdoc" integer,
    "numerodoc" text,
    "ciuemidesc" varchar,
    "paisemidesc" varchar,
    "paisemi" varchar,
    "nroconstancia" varchar,
    "nrocontrol" varchar,
    PRIMARY KEY ("id")
);



CREATE TABLE "salidadetalle" (
    "id" integer NOT NULL,
    "producto_id" integer NOT NULL,
    "codigo_producto" text NOT NULL,
    "deposito_id" integer NOT NULL,
    "sucursal_id" integer NOT NULL,
    "linea" integer NOT NULL,
    "cantidad" integer NOT NULL,
    PRIMARY KEY ("id", "linea")
);



CREATE TABLE "categorias" (
    "id" integer NOT NULL,
    "producto_id" integer NOT NULL UNIQUE,
    "nombre_categoria" text NOT NULL UNIQUE,
    "codigo_categoria" text UNIQUE,
    "fecha_creacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "precios" (
    "id" integer NOT NULL,
    "producto_id" integer NOT NULL UNIQUE,
    "precio" integer NOT NULL,
    "activo" boolean NOT NULL,
    "iva" bigint NOT NULL,
    "tipo_precio" varchar,
    "moneda" text NOT NULL,
    "fecha_creacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "transferenciasDepositos" (
    "id" integer NOT NULL,
    "numero" integer NOT NULL,
    "observacion" text,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_modificacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "stock" (
    "id" integer NOT NULL,
    "factura_id" integer NOT NULL,
    "linea" integer NOT NULL,
    "producto_id" integer NOT NULL,
    "codigo_producto" text NOT NULL,
    "cantidad" integer NOT NULL,
    "entrada_id" integer NOT NULL,
    "precio_entrada" integer NOT NULL,
    "preciome_entrada" decimal NOT NULL,
    "totalLocal" integer,
    "totalMe" decimal,
    "origen" text NOT NULL,
    "moneda" text NOT NULL,
    "fecha_creacion" timestamp NOT NULL,
    "deposito_id" integer NOT NULL,
    PRIMARY KEY ("id", "linea", "origen")
);



CREATE TABLE "salidaStock" (
    "id" integer NOT NULL,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_modificacion" timestamp NOT NULL,
    PRIMARY KEY ("id")
);



CREATE TABLE "entradaStock" (
    "id" integer NOT NULL,
    "sucursal_id" integer NOT NULL,
    "numero_entrada" integer NOT NULL,
    "moneda" text NOT NULL,
    "fecha_creacion" timestamp NOT NULL,
    "fecha_modificacion" timestamp NOT NULL,
    "cotizacion" numeric,
    PRIMARY KEY ("id")
);



CREATE TABLE "chofer" (
    "id" integer NOT NULL,
    "id_transportista" integer NOT NULL,
    "nombre" bigint NOT NULL,
    "documento" bigint NOT NULL,
    PRIMARY KEY ("id")
);



ALTER TABLE "caja"
ADD CONSTRAINT "fk_caja_id_deposito_depositos_id" FOREIGN KEY("id_deposito") REFERENCES "depositos"("id");

ALTER TABLE "caja"
ADD CONSTRAINT "fk_caja_id_sucursal_sucursales_id" FOREIGN KEY("id_sucursal") REFERENCES "sucursales"("id");

ALTER TABLE "categorias"
ADD CONSTRAINT "fk_categorias_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "entradadetalle"
ADD CONSTRAINT "fk_entradadetalle_deposito_id_depositos_id" FOREIGN KEY("deposito_id") REFERENCES "depositos"("id");

ALTER TABLE "entradadetalle"
ADD CONSTRAINT "fk_entradadetalle_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "entradaStock"
ADD CONSTRAINT "fk_entradaStock_sucursal_id_sucursales_id" FOREIGN KEY("sucursal_id") REFERENCES "sucursales"("id");

ALTER TABLE "imagenesProductos"
ADD CONSTRAINT "fk_imagenesProductos_id_producto_productos_id" FOREIGN KEY("id_producto") REFERENCES "productos"("id");

ALTER TABLE "precios"
ADD CONSTRAINT "fk_precios_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "productos"
ADD CONSTRAINT "fk_productos_categoria_id_categorias_id" FOREIGN KEY("categoria_id") REFERENCES "categorias"("id");

ALTER TABLE "salidadetalle"
ADD CONSTRAINT "fk_salidadetalle_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "salidadetalle"
ADD CONSTRAINT "fk_salidadetalle_sucursal_id_sucursales_id" FOREIGN KEY("sucursal_id") REFERENCES "sucursales"("id");

ALTER TABLE "stock"
ADD CONSTRAINT "fk_stock_deposito_id_depositos_id" FOREIGN KEY("deposito_id") REFERENCES "depositos"("id");

ALTER TABLE "stock"
ADD CONSTRAINT "fk_stock_entrada_id_entradaStock_id" FOREIGN KEY("entrada_id") REFERENCES "entradaStock"("id");

ALTER TABLE "stock"
ADD CONSTRAINT "fk_stock_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "vehiculo"
ADD CONSTRAINT "fk_vehiculo_id_transportista_transportistas_id" FOREIGN KEY("id_transportista") REFERENCES "transportistas"("id");

ALTER TABLE "transferenciadepDetalle"
ADD CONSTRAINT "fk_transferenciadepDetalle_producto_id_productos_id" FOREIGN KEY("producto_id") REFERENCES "productos"("id");

ALTER TABLE "chofer"
ADD CONSTRAINT "fk_chofer_id_transportista_transportistas_id" FOREIGN KEY("id_transportista") REFERENCES "transportistas"("id");
