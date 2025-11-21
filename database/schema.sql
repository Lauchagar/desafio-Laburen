CREATE TYPE cart_status AS ENUM (
    'activo',
    'completado',
    'abandonado'
);
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    tipo_prenda VARCHAR(100) NOT NULL,
    talla VARCHAR(20),
    color VARCHAR(50),
    cantidad_disponible INT NOT NULL DEFAULT 0,
    precio_50_u DECIMAL(10, 2) NOT NULL,
    precio_100_u DECIMAL(10, 2) NOT NULL,
    precio_200_u DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE,
    categoria VARCHAR(100),
    descripcion TEXT
);
CREATE TABLE IF NOT EXISTS carts (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    estado cart_status NOT NULL DEFAULT 'activo',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS cart_items (
    id SERIAL PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    
    CONSTRAINT fk_cart
        FOREIGN KEY(cart_id) 
        REFERENCES carts(id)
        ON DELETE CASCADE, 
    
    CONSTRAINT fk_product
        FOREIGN KEY(product_id) 
        REFERENCES products(id)
        ON DELETE RESTRICT 
);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_carts_user_id ON carts(user_id);
CREATE EXTENSION IF NOT EXISTS unaccent;