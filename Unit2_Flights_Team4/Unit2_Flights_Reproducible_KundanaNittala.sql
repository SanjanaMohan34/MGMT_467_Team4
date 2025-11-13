BEGIN TRANSACTION;
CREATE TABLE "products" (
"product_id" INTEGER,
  "name" TEXT,
  "price" REAL,
  "in_stock" INTEGER
);
INSERT INTO "products" VALUES(101,'Laptop',1200.5,1);
INSERT INTO "products" VALUES(102,'Mouse',25.0,1);
INSERT INTO "products" VALUES(103,'Monitor',350.99,0);
COMMIT;