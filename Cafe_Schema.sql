-- Login as admin 
-- For safer way sqlplus sys@locahost:1521 as sysdba
sqlplus sys/p1a2s0s3word@locahost:1521 as sysdba

-- PLUGGABLE DATABASE
CREATE PLUGGABLE DATABASE Dev_Cafe admin user Links IDENTIFIED BY zelda \
create_file_dest='/home/oracle';

-- Set permision
ALTER PLUGGABLE DATABASE Dev_Cafe OPEN;
EXIT

-- Log in to the database
-- For safer way sqlplus sys@localhost:1521/Dev_cafe as sysdba
sqlplus sys/p1a2s0s3word@localhost:1521/Dev_Cafe as sysdba

-- Grant access to Link
GRANT DBA to link CONTAINER = ALL

-- Developer Acess

CREATE ROLE dev_ROLE;

GRANT CONNECT, CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE TRIGGER, CREATE SYNONYM TO dev_ROLE;

CREATE USER Dev_Hyrule IDENTIFIED BY dev_Password

GRANT dev_ROLE TO Dev;

GRANT UNLIMITED TABLESPACE TO Dev;

-- Production Access after the schema is created

CREATE ROLE prod_ROLE;

BEGIN
  FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'Dev_cafe') LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON ' || 'Dev_cafe' || t.table_name || ' TO prod_ROLE';
  END LOOP;
END;
/

CREATE USER Prod IDENTIFIED BY ProdPassword

GRANT prod_ROLE TO Prod

EXIT

--  DBA As link
-- safe way sqlplus Link@localhost:1521/Dev_Cafe
sqlplus Link/zelda@localhost:1521/Dev_Cafe

---- Schema --------------------------
--1
CREATE TABLE "current_inventory" (
  "current_inventory_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "item_name" VARCHAR2(50) NOT NULL,
  "description" VARCHAR2(50),
  "unit" VARCHAR2(50) NOT NULL, -- Fixed typo: "VARHCAR" to "VARCHAR"
  "category" CHAR(10) NOT NULL,
  "create_at" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);
--2
CREATE TABLE "Details" (
  "details_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "payment_id" NUMBER NOT NULL,
  "description" VARCHAR2(50),
  "amount_paid" NUMBER(10,2),
  "DebitCredit" VARCHAR2(10) -- Made VARCHAR to VARCHAR2 for consistency
);
--3
CREATE TABLE "Attachment" (
  "attachment_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "details_id" NUMBER NOT NULL,
  "file_path" VARCHAR2(255),
  "upload_at" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT "FK_Attachment.details_id"
    FOREIGN KEY ("details_id")
      REFERENCES "Details"("details_id")
);
--4
CREATE TABLE "order_items" (
  "order_count" NUMBER NOT NULL,
  "menu_id" NUMBER NOT NULL,
  "quantity" NUMBER -- Fixed typo: "quantiity" to "quantity"
);
--5
CREATE TABLE "order_count" (
  "order_count" NUMBER NOT NULL,
  "order_date" DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT "FK_order_count.order_count"
    FOREIGN KEY ("order_count")
      REFERENCES "order_items"("order_count")
);
--6
CREATE TABLE "menu" (
  "menu_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "item_name" VARCHAR2(100),
  "price" NUMBER(5,2),
  "category" VARCHAR2(50),
  "availability_status" NUMBER(1) DEFAULT 1 NOT NULL CHECK ("availability_status" IN (1, 0)) -- Removed space
);
--7
CREATE TABLE "per_single_serving" (
  "menu_id" NUMBER NOT NULL, -- Changed type for consistency with menu_id type
  "amount" NUMBER(5,2) NOT NULL,
  "current_inventory_id" NUMBER NOT NULL,
  CONSTRAINT "FK_per_single_serving.menu_id"
    FOREIGN KEY ("menu_id")
      REFERENCES "menu"("menu_id"),
  CONSTRAINT "FK_per_single_serving.current_inventory_id"
    FOREIGN KEY ("current_inventory_id")
      REFERENCES "current_inventory"("current_inventory_id")
);
--8
CREATE TABLE "discount" (
  "discount_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "discount_name" VARCHAR2(15),
  "discount_rate" NUMBER,
  "date_effective" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);
--9
CREATE TABLE "current_inventory_details" (
  "current_inventory_details" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "stock_amount" NUMBER(10,2) DEFAULT 0 NOT NULL,
  "current_inventory_id" NUMBER NOT NULL,
  CONSTRAINT "FK_current_inventory_details.current_inventory_id"
    FOREIGN KEY ("current_inventory_id")
      REFERENCES "current_inventory"("current_inventory_id")
);
--10
CREATE TABLE "inventory_transaction" (
  "inventory_transaction_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Fixed typo: "DEFAUL" to "DEFAULT"
  "stock_quantity" NUMBER(5,2) NOT NULL,
  "action" VARCHAR2(10) DEFAULT 'Add' NOT NULL CHECK (action IN ('Add', 'Used')), -- Added type and fixed DEFAULT syntax
  "current_inventory_details" NUMBER NOT NULL,
  "last_updated" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT "FK_inventory_transaction.current_inventory_details"
    FOREIGN KEY ("current_inventory_details")
      REFERENCES "current_inventory_details"("current_inventory_details")
);
--11
CREATE TABLE "Staff" (
  "staff_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "first" VARCHAR2(50) NOT NULL,
  "last" VARCHAR2(50) NOT NULL,
  "position" VARCHAR2(50),
  "salary" NUMBER(5,2) CHECK (salary > 0), -- Removed extra comma
  "hire_date" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  "email" VARCHAR2(20) UNIQUE
);
--12
CREATE TABLE "payments" (
  "payment_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "order_count" NUMBER NOT NULL,
  "payment_date" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  "payment_method" VARCHAR2(10) DEFAULT 'Cash' NOT NULL CHECK (payment_method IN ('Cash', 'Card', 'Mobile')), -- Fixed quotes and VARCHAR2
  "pay_amount" NUMBER(10,2),
  "received_amount" NUMBER(10,2),
  "staff_id" NUMBER NOT NULL,
  "discount_id" NUMBER NOT NULL,
  "status" VARCHAR2(10) DEFAULT 'Pending' NOT NULL CHECK ("status" IN ('Pending', 'Cancelled', 'Complete')), -- Fixed CHECK syntax
  CONSTRAINT "FK_payments.order_count"
    FOREIGN KEY ("order_count")
      REFERENCES "order_count"("order_count"),
  CONSTRAINT "FK_payments.discount_id"
    FOREIGN KEY ("discount_id")
      REFERENCES "discount"("discount_id"),
  CONSTRAINT "FK_payments.staff_id"
    FOREIGN KEY ("staff_id")
      REFERENCES "Staff"("staff_id"),
  CONSTRAINT "FK_payments.payment_id"
    FOREIGN KEY ("payment_id")
      REFERENCES "Details"("payment_id")
);
--13
CREATE TABLE "adds_on" (
  "order_count" NUMBER NOT NULL,
  "menu_id" NUMBER NOT NULL,
  "quantity" NUMBER(5,2) NOT NULL,
  CONSTRAINT "FK_adds_on.order_count"
    FOREIGN KEY ("order_count")
      REFERENCES "order_items"("order_count"),
  CONSTRAINT "FK_adds_on.menu_id"
    FOREIGN KEY ("menu_id")
      REFERENCES "menu"("menu_id")
);


-------------------- Index ------------------------

-- CREATE INDEX idx_staff_name
-- on staff (First,  Last)

-- CREATE UNIQUE idx_staff_email
-- on staff ( email )

-- CREATE INDEX idx_order_count
-- on order_items (order_count)

-- CREATE INDEX idx_menu_category
-- on menu (category)

-- CREATE INDEX idx_payment_status
-- ON payment (status)

-- CREATE INDEX idx_payment_method
-- ON payment (payment_method)

-- CREATE INDEX idx_inventory_stock_check
-- ON inventory_transaction (current_inventory_id, stock_quantity);

-------------------- Package Collection ------------------------
CREATE OR REPLACE PACKAGE arrayData AS
    TYPE ArrayNUMBER IS TABLE OF NUMBER;        -- Array of numbers
    TYPE ArrayVARCHAR IS TABLE OF VARCHAR2(50);  -- Array of strings with max length 10
    TYPE ArrayBOOLEAN IS TABLE OF NUMBER(1)       -- Array of characters (1/0) as BOOLEAN
    TYPE ArrayDATE IS TABLE OF DATE;             -- Array of DATE values
    TYPE ArrayTIMESTAMP IS TABLE OF TIMESTAMP;   -- Array of TIMESTAMP values
    Type ArrayDECIMAL IS TABLE OF NUMBER(10,2)
END arrayData;

-------------------- Create ------------------------
CREATE OR REPLACE PROCEDURE Order_Count_Increment (
    order_out OUT NUMBER
) IS
BEGIN
    SELECT order_count INTO order_out
    FROM order_count 
  
    UPDATE order_count
    SET order_count = order_count + 1

      COMMIT;

EXCEPTION 
WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('No data found for today.');
      END;
END;
/

CREATE OR REPLACE PROCEDURE insert_current_inventory_bulk(
in_item_name IN VARCHAR2(50),
in_brand_nameIN NUMBER(5,2),
in_stock_quantity IN VARCHAR2(10),
in_unit IN NUMBER (1),
in_category IN NUMBER
)
IS 
DECLARE
input_check EXCEPTION;

BEGIN

FOR i IN 1  . . in_item_name.COUNT LOOP
IF LENGTH(in_item_name(i)) >= 0  OR in_stock_quantity(i) > = 0 THEN
    RAISE input_check;
ELSE 

INSERT INTO current_inventory (item_name, brand_name, stock_quantity, unit,category) 
VALUES (in_item_name(i), in_brand_name(i), in_stock_quantity(i), in_unit(i), in_category(i))

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;
END LOOP;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
   WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/


CREATE OR REPLACE PROCEDURE insert_menu_bulk(
in_item_name IN ArrayVarchar,
in_description IN ArrayVarchar,
in_price IN ArrayDecimal,
in_availability_status IN ArrayBoolean,
in_category IN ArrayVarchar,
in_order_inventory_description_id IN ArrayNUMBER

)
IS 

DECLARE
input_check EXCEPTION;

BEGIN

FOR i IN 1 . . in_item_name.COUNT LOOP
IF  LENGTH(in_item_name(i)) >= 0 OR in_stock_quantity(0) > 0 THEN
    RAISE input_check;
ELSE
INSERT INTO menu (item_name, description, price,category, availability_status,order_inventory_description_id ) 
VALUES (in_item_name(i), in_description(i), in_price, in_category(i), in_availability_status(i), in_order_inventory_description_id(i))

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;
END LOOP;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');
END;
/


CREATE OR REPLACE PROCEDURE order_items_bulks(
in_order_count IN ArrayData.ArrayNumber,
in_item_id IN ArrayData.ArrayNumber,
in_quantity IN ArrayData.ArrayNumber,
in_subtotal IN ArrayData.ArrayDecimal
)
IS

DECLARE

input_validation_check EXCEPTION;

BEGIN

FOR I IN 1 .. in_order_count.COUNT LOOP
IF in_quantity(i) > 0 OR in_subtotal(1) > 0 THEN
    RAISE input_validation_check;
ELSE
INSERT INTO order_items (order_count, item_id, quantity, subtotal) 
VALUES (in_order_count(i), in_item_id(i), in_quantity(i), in_subtota(i)l)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;

END LOOP;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
    WHEN input_validation_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');

END;
/



CREATE OR REPLACE PROCEDURE order_items_selection(
in_order_count IN NUMBER,
in_item_id IN NUMBER,
in_quantity IN NUMBER,
in_subtotal IN NUMBER (6,2)
)
IS 

DECLARE 

quantity_subtotal_check EXCEPTION;

BEGIN

IF in_quantity > 0 OR in_subtotal > 0 THEN
    RAISE quantity_subtotal_check;
ELSE
INSERT INTO order_items (order_count, item_id, quantity, subtotal) 
VALUES (in_order_count, in_item_id, in_quantity, in_subtotal)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
    WHEN quantity_subtotal_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');
END;
/

CREATE OR REPLACE PROCEDURE single_serving(
in_size IN VARCHAR2(50),
in_amount IN NUMBER(5,2),
in_unit_size IN VARCHAR2(10),
in_availability IN NUMBER (1),
in_inventory_id IN NUMBER 
)
IS 
DECLARE
amount_unitsize_check EXCEPTION;

BEGIN

IF in_amount > 0 OR in_unit_size > = 0 THEN
    RAISE amount_unitsize_check;

ELSE 
INSERT INTO  single_serving (size, amount, Unit_use, Availabitity,Inventory_id) 
VALUES (in_size, in_amount, in_Unit_use, in_Availabitity, in_Inventory_id)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;


EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
   WHEN amount_unitsize_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/


CREATE OR REPLACE PROCEDURE insert_current_inventory(
in_item_name IN VARCHAR2(50),
in_brand_nameIN NUMBER(5,2),
in_stock_quantity IN VARCHAR2(10),
in_unit IN NUMBER (1),
in_category IN NUMBER
)
IS 
DECLARE
input_check EXCEPTION;

BEGIN

IF LENGTH(in_item_name) >= 0  OR in_stock_quantity > = 0 THEN
    RAISE input_check;
ELSE 

INSERT INTO current_inventory (item_name, brand_name, stock_quantity, unit,category) 
VALUES (in_item_name, in_brand_name, in_stock_quantity, in_unit, in_category)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;


EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
   WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/

CREATE OR REPLACE PROCEDURE insert_menu(
in_item_name IN VARCHAR2(100),
in_description IN VARCHAR2(50),
in_price IN NUMBER(5,2),
in_availability_status IN NUMBER(1),
in_category IN VARCHAR2(50),
in_order_inventory_description_id IN NUMBER

)
IS 

DECLARE
input_check EXCEPTION;

BEGIN

IF  LENGTH(in_item_name) >= 0 OR in_stock_quantity > 0 THEN
    RAISE input_check;
ELSE
INSERT INTO menu (item_name, description, price,category, availability_status,order_inventory_description_id ) 
VALUES (in_item_name, in_description, in_price, in_category, in_availability_status, in_order_inventory_description_id)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

END IF;


EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/

CREATE OR REPLACE PROCEDURE insert_current_inventory(
in_Discount_name IN VARCHAR2(50),
in_Discount_rate IN NUMBER(5,2),
in_Date_effective IN VARCHAR2(10)
)
IS 

DECLARE
input_check EXCEPTION
BEGIN
IF  LENGTH(in_Discount_name) >= 0 OR in_Discount_rate > 0 THEN
    RAISE input_check;

ELSE 

INSERT INTO current_inventory (Discount_name, Discount_rate, Date_effective) 
VALUES (in_Discount_name, in_Discount_rate, in_Date_effective)

DBMS_OUTPUT.PUT_LINE('Insert successful.');
COMMIT;


END IF;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/

CREATE OR REPLACE PROCEDURE insert_payment(
in_order_count IN NUMBER ,   
in_payment_method IN VARCHAR(10), 
in_Amount_paid IN NUMBER(10,2),  
in_discount IN NUMBER,
in_staff IN NUMBER,  
in_status IN NUMBER
)
IS

DECLARE
input_check EXCEPTION
BEGIN
IF  in_discount >= 0 OR in_Amount_paid >= 0 THEN
    RAISE input_check;

ELSE

INSERT INTO payments (order_count,   payment_method, Amount_paid,  discount, status, staff_id)
VALUES (in_order_count,  in_payment_date, in_payment_method, in_Amount_paid,  in_discount, in_status,in_staff)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;


END IF;
   

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient funds for withdrawal.');


END;
/

CREATE OR REPLACE PROCEDURE Attachment (
    in_details_id IN NUMBER,
    in_file_path IN VARCHAR2
) IS


BEGIN
    INSERT INTO Attachment (details_id, file_path)
    VALUES (in_details_id, in_file_path);

    DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);

END;
/

CREATE OR REPLACE PROCEDURE insert_staff(
in_First IN VARCHAR(50),   
in_Last IN VARCHAR(50), 
in_position IN VARCHAR(50),  
in_salary  IN NUMBER (5,2) 
in_email IN VARCHAR(50)
)
IS
DECLARE  

input_check EXCEPTION;

BEGIN

IF INSTER(in_email, '@') > THEN 

INSERT INTO staff (First, Last, position, salary, email)
VALUES (in_First, in_Last, in_position, in_salary, in_email)

DBMS_OUTPUT.PUT_LINE('Insert successful.');

ELSE 
RAISE input_check;

COMMIT;

ENDIF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Duplicate value. Check the unique constraint.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value too large or invalid datatype.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
   WHEN input_check THEN
       DBMS_OUTPUT.PUT_LINE('ERROR: Put a valid email address');


END;
/

--------------------u Update u------------------------
CREATE OR REPLACE PROCEDURE order_items_update(
In_order_item_id IN NUMBER,
in_order_count IN NUMBER,
in_item_id IN NUMBER,
in_quantity IN NUMBER,
in_subtotal IN NUMBER (6,2)
)
IS 

BEGIN
UPDATE	 order_items
SET		 order_count = in_order_count,
 item_id = in_item_id, 
quantity = in_quantity, 
subtotal = in_subtotal
WHERE	order_item_id = In_order_item_id

DBMS_OUTPUT.PUT_LINE('Update successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END; 
/

CREATE OR REPLACE PROCEDURE single_serving_description(
In_single_serving_id IN NUMBER,
in_size IN VARCHAR2(50),
in_amount IN NUMBER(5,2),
in_unit_size IN VARCHAR2(10),
in_ Availability IN NUMBER (1),
in_inventory_id IN NUMBER 
)
IS 

BEGIN

UPDATE 	single_serving 
SET size = 	in_size, 
amount = in_amount, 
unit = in_unit, 
Availability = in_ Availability, 
current_inventory_id  = in_inventory_id
WHERE	 single_serving_id = In_single_serving_id

DBMS_OUTPUT.PUT_LINE('Update successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 

END;
/

CREATE OR REPLACE PROCEDURE insert_current_inventory(
In_current_inventory_id IN NUMBER,
in_item_name IN VARCHAR2(50),
in_brand_nameIN NUMBER(5,2),
in_stock_quantity IN VARCHAR2(10),
in_unit IN NUMBER (1),
in_category IN NUMBER,
in_create IN TIMESTAMP
)
IS 

BEGIN
UPDATE 	current_inventory
SET 		size = item_name, 
amount = in_item_name, 
brand_name = in_brand_name, 
stock_quantity = in_stock_quantity, 
unit = in_unit,
category = in_category
WHERE 	current_inventory_id= In_current_inventory_id
DBMS_OUTPUT.PUT_LINE('Insert successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

CREATE OR REPLACE PROCEDURE insert_menu(
In_ item_id IN NUMBER,
in_item_name IN VARCHAR2(100),
in_description IN VARCHAR2(50),
in_price IN NUMBER(5,2),
in_availability_status IN NUMBER(1),
in_category IN VARCHAR2(50),
in_ single_serving_id IN NUMBER
)
IS 
BEGIN

UPDATE` 	menu
SET		item_name = in_item_name, 
Description = in_description, 
Price = in_price,
Category = in_category, 
availability_status = in_availability_status, 
single_serving_id = in_ single_serving_id
WHERE	item_id = In_ item_id
DBMS_OUTPUT.PUT_LINE('Update successful.');
COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

CREATE OR REPLACE PROCEDURE Update_discount(	
In_ discount_id IN NUBER,
in_Discount_name IN VARCHAR2(50),
in_Discount_rate IN NUMBER(5,2),
in_Date_effective IN VARCHAR2(10)
)
IS 

BEGIN
UPDATE	discount
SET		Discount_name = in_Discount_name, 
Discount_rate =  in_Discount_rate, 
Date_effective = in_Date_effective
WHERE 	discount_id = In_ discount_id

DBMS_OUTPUT.PUT_LINE('Update successful.');
COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END; 
/

CREATE OR REPLACE PROCEDURE insert_payment(
In_ payment_id IN NUMBER,
in_order_count IN NUMBER ,   
in_payment_method IN VARCHAR(10), 
in_Amount_paid IN NUMBER(10,2),  
in_discount IN NUMBER,
in_staff IN NUMBER, 
in_status IN NUMBER
)
IS

BEGIN

UPDATE	payments
SET		order_count = in_order_count,   
 payment_method = in_payment_method,
 Amount_paid in_Amount_paid, 
 Discount = in_discount, 
Status = in_status, 	
Staff = in_staff
WHERE 	payment_id = In_ payment_id

DBMS_OUTPUT.PUT_LINE('Update successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

CREATE OR REPLACE PROCEDURE Attachment (
In_attachment_id IN NUMBER,
    in_details_id IN NUMBER,
    in_file_path IN VARCHAR2,
in_upload_at IN TIMESTAMP
) IS
UPDATE	Attachment
SET 		details_id = in_details_id,
    		file_path = in_file_path,
upload_at = in_upload_at
WHERE 	attachment_id = In_attachment_id

    DBMS_OUTPUT.PUT_LINE('Update successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

CREATE OR REPLACE PROCEDURE insert_staff(
In_staff_id IN NUMBER,
in_First IN VARCHAR(50),   
in_Last IN VARCHAR(50), 
in_position IN VARCHAR(50),  
in_salary  IN NUMBER (5,2) 
in_email IN VARCHAR(50)
)
IS

BEGIN

UPDATE 	staff
SET 
First = in_First, 
Last = in_Last, 
Position = in_position, 
Salary = in_salary  ,
Email = in_email
WHERE 	staff_id = In_staff_id

DBMS_OUTPUT.PUT_LINE('Update successful.');

COMMIT;

EXCEPTION 
WHEN DUP_VAL_ON_INDEX THEN 
DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
WHEN INVALID_NUMBER THEN 
DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
WHEN OTHERS THEN 
DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

--------------------  Trigger ------------------------
CREATE OR REPLACE TRIGGER trigger_after_insert_payments
AFTER INSERT ON payments
FOR EACH ROW
DECLARE
BEGIN
    -- Only update inventory when stock quantity is required
    IF EXISTS (
        SELECT 1
        FROM order_items oi
        WHERE oi.order_count = :NEW.order_count
    ) THEN
        INSERT INTO inventory_transaction (stock_quantity, action, current_inventory_id)
        SELECT oi.quantity * oid.amount AS stock_quantity, 'Used' AS action, oid.current_inventory_id
        FROM order_items oi
        JOIN menu m ON m.item_id = oi.item_id
        JOIN single_serving oid ON m.single_serving_id = oid.single_serving_id
        WHERE oi.order_count = :NEW.order_count;

    END IF;

COMMIT;

WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No data found for today.');

END;
/

-- API Json Ready

CREATE OR REPLACE PROCEDURE insert_order_items_JSON(
    v_json_data IN CLOB
)
IS
    v_json_array JSON_ARRAY_T := JSON_ARRAY_T(v_json_data);
    v_order_item JSON_OBJECT_T;
    v_item_o JSON_OBJECT_T;
    v_item_a JSON_ARRAY_T;
    v_add_on_a JSON_ARRAY_T;
    v_add_on_o JSON_OBJECT_T;
    v_order_count NUMBER;
    ToF NUMBER(1) := 1;
BEGIN
    FOR i IN 1..v_json_array.get_size LOOP
        v_order_item := v_json_array.get_object(i);
        v_order_count := v_order_item.get_number('count');
        v_item_a := v_order_item.get_array('items');
        INSERT INTO order_count(order_count)
        VALUES (v_order_count)
        
        FOR j IN 1..v_item_a.get_size LOOP
            v_item_o := v_item_a.get_object(j);

            IF v_item_o.get_array('add_on') IS NULL THEN 
                v_add_on_a := NULL; 
                ToF := 1; 
            ELSE 
                v_add_on_a := v_item_o.get_array('add_on'); 
                ToF := 0; 
            END IF;

            INSERT INTO order_items (order_count, menu_id, quantity)
            VALUES (v_order_count, v_item_o.get_number('menu'), v_item_o.get_number('quantity'), v_item_o.get_number('subtotal'));
            
            IF ToF = 0 THEN
                FOR f IN 1..v_add_on_a.get_size LOOP    
                    v_add_on_o := v_add_on_a.get_object(f);
                    INSERT INTO adds_on (order_count, menu_id, quantity)
                    VALUES (v_order_count, v_item_o.get_number('menu'), v_add_on_o.get_number('quantity'));
                END LOOP; 
            END IF;    
        END LOOP;
    END LOOP;
    COMMIT;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

-- DECLARE
--     v_json_data CLOB := '[
--         { "id": 1, "name": "John Doe", "position": "Manager", "salary": 80000 },
--         { "id": 2, "name": "Jane Smith", "position": "Analyst", "salary": 60000 }
--     ]';
-- BEGIN
--     -- Insert data directly using JSON_TABLE and JSON_VALUE
--     INSERT INTO staff_table (id, name, position, salary)
--     SELECT 
--         JSON_VALUE(ji.value, '$.id'), 
--         JSON_VALUE(ji.value, '$.name'), 
--         JSON_VALUE(ji.value, '$.position'), 
--         JSON_VALUE(ji.value, '$.salary')
--     FROM JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' 
--         COLUMNS (value CLOB PATH '$')) ji;

--     COMMIT;
-- EXCEPTION 
--     WHEN DUP_VAL_ON_INDEX THEN 
--         DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
--     WHEN INVALID_NUMBER THEN 
--         DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
--     WHEN OTHERS THEN 
--         DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
-- END;
-- /

DECLARE OR REPLACE insert_staff(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO staff (first, last, position, salary, hire_date, email)
    SELECT 
        JSON_VALUE(ji.value, '$.first'), 
        JSON_VALUE(ji.value, '$.last'), 
        JSON_VALUE(ji.value, '$.position'), 
        JSON_VALUE(ji.value, '$.salary'), 
        JSON_VALUE(ji.value, '$.hire_date'), 
        JSON_VALUE(ji.value, '$.email')
    FROM JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

    COMMIT;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

DECLARE OR REPLACE insert_discount(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO discount (discount_name, discount_rate, date_effective)
    SELECT 
        JSON_VALUE(ji.value, '$.discount_name'), 
        JSON_VALUE(ji.value, '$.discount_rate'), 
        JSON_VALUE(ji.value, '$.date_effective')
    FROM JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

    COMMIT;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

DECLARE OR REPLACE insert_payments(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO payments (order_count, payment_method, pay_amount, recieved_amount, staff_id, discount_id, status)
    SELECT 
        JSON_VALUE(ji.value, '$.order_count'), 
        JSON_VALUE(ji.value, '$.payment_method'), 
        JSON_VALUE(ji.value, '$.recieved_amount'),
        JSON_VALUE(ji.value, '$.staff_id'), 
        JSON_VALUE(ji.value, '$.discount_id'), 
        JSON_VALUE(ji.value, '$.status')
        
    FROM JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

    COMMIT;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

DECLARE OR REPLACE insert_menu(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO menu (item_name, price, category, availability_status)
    SELECT 
        JSON_VALUE(ji.value, '$.item_name'), 
        JSON_VALUE(ji.value, '$.price'), 
        JSON_VALUE(ji.value, '$.category'),
        JSON_VALUE(ji.value, '$.availability_status') 
        
    FROM JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

    COMMIT;
EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/

DECLARE OR REPLACE insert_inventory(
    v_JSON IN CLOB
)
IS
    v_inventory_a JSON_ARRAY_T := JSON_ARRAY_T(v_JSON)
    v_inventory_o JSON_OBJECT_T;
    v_inventory_details_a JSON_ARRAY_T;
    v_inventory_details_o JSON_OBJECT_T;
    v_current_inventory_id NUMBER;

BEGIN

    FOR i IN 1 .. v_inventory_a.get_size LOOP
        v_inventory_o := v_inventory_a.get_object(i)
        INSERT INTO current_inventory(item_name, description, unit, category)
        VALUES (v_inventory_o.get_number('item_name'), v_inventory_o.get_number('description'),v_inventory_o.get_number('unit'), v_inventory_o.get_number('category'))
        RETURNING current_inventory_id INTO v_current_inventory_id;
        v_inventory_details_a = v_inventory_o.get_array(i)

        FOR j IN 1 .. v_inventory_details_a.get_size LOOP
            v_inventory_details_o := v_inventory_details_a.get_object(j)
            INSERT INTO current_inventory_details (stock_amount, current_inventory_id)
            VALUES (v_inventory_o.get_number('stock_amount'), v_current_inventory_id);
        END LOOP

    END LOOP

COMMIT;

EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('Duplicate value encountered.'); 
    WHEN INVALID_NUMBER THEN 
        DBMS_OUTPUT.PUT_LINE('Invalid data encountered.'); 
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM); 
END;
/