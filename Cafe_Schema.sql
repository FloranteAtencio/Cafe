---- Schema --------------------------
--  TABLE "order_count";
CREATE TABLE "order_count" (
  "order_count" NUMBER,
  "order_date" DATE DEFAULT SYSDATE NOT NULL,
  PRIMARY KEY ("order_count")
)
PARTITION BY RANGE ("order_date") INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH')) (
  PARTITION p_initial VALUES LESS THAN (TO_DATE('2024-10-01', 'YYYY-MM-DD'))
);
--  TABLE "menu";
CREATE TABLE "menu" (
  "menu_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "item_name" VARCHAR2(100),
  "price" NUMBER(5,2),
  "category" VARCHAR2(50),
  "availability_status" NUMBER(1) DEFAULT 1 NOT NULL CHECK ("availability_status" IN (1, 0)) 
);
--  TABLE "discount";
CREATE TABLE "discount" (
  "discount_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "discount_name" VARCHAR2(15),
  "discount_rate" NUMBER,
  "date_effective" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);
--  TABLE "Staff";
CREATE TABLE "staff" (
  "staff_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "first" VARCHAR2(50) NOT NULL,
  "last" VARCHAR2(50) NOT NULL,
  "position" VARCHAR2(50),
  "salary" NUMBER(5,2) CHECK ("salary" > 0), -- Removed extra comma
  "hire_date" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  "email" VARCHAR2(20) UNIQUE
);
--  TABLE "adds_on";
CREATE TABLE "adds_on" (
  "order_count" NUMBER NOT NULL,
  "menu_id" NUMBER NOT NULL,
  "quantity" NUMBER(5,2) NOT NULL,
    PRIMARY KEY ("order_count", "menu_id"),
  CONSTRAINT "FK_adds_on.menu_id"
    FOREIGN KEY ("menu_id")
      REFERENCES "menu"("menu_id")
);
--  TABLE "order_items";
CREATE TABLE "order_items" (
  "order_count" NUMBER NOT NULL,
  "menu_id" NUMBER NOT NULL,
  "quantity" NUMBER,
  PRIMARY KEY ("order_count", "menu_id"),
  CONSTRAINT "FK_order_count"
    FOREIGN KEY ("order_count")
      REFERENCES "order_count"("order_count"),
       CONSTRAINT "FK_menu_id"
    FOREIGN KEY ("menu_id")
      REFERENCES "menu"("menu_id")
);
--  TABLE "current_inventory";
CREATE TABLE "current_inventory" (
  "current_inventory_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "item_name" VARCHAR2(50) NOT NULL,
  "description" VARCHAR2(50),
  "unit" VARCHAR2(50) NOT NULL, 
  "category" CHAR(10) NOT NULL,
  "create_at" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);
--  TABLE "per_single_serving";
CREATE TABLE "per_single_serving" (
  "menu_id" NUMBER NOT NULL, 
  "amount" NUMBER(5,2) NOT NULL,
  "current_inventory_id" NUMBER NOT NULL,
  CONSTRAINT "FK_per_single_serving.menu_id"
    FOREIGN KEY ("menu_id")
      REFERENCES "menu"("menu_id"),
  CONSTRAINT "FK_per_single_serving.current_inventory_id"
    FOREIGN KEY ("current_inventory_id")
      REFERENCES "current_inventory"("current_inventory_id")
);
--  TABLE "current_inventory_details";
CREATE TABLE "current_inventory_details" (
  "current_inventory_details" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "stock_amount" NUMBER(10,2) DEFAULT 0 NOT NULL,
  "current_inventory_id" NUMBER NOT NULL,
  CONSTRAINT "FK_current_inventory_details.current_inventory_id"
    FOREIGN KEY ("current_inventory_id")
      REFERENCES "current_inventory"("current_inventory_id")
);
--  TABLE "inventory_transaction";
CREATE TABLE "inventory_transaction" (
  "inventory_transaction_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Fixed typo: "DEFAUL" to "DEFAULT"
  "stock_quantity" NUMBER(5,2) NOT NULL,
  "action" VARCHAR2(10) DEFAULT 'Add' NOT NULL CHECK ("action" IN ('Add', 'Used')), -- Added type and fixed DEFAULT syntax
  "current_inventory_details" NUMBER NOT NULL,
  "last_updated" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT "FK_inventory_transaction.current_inventory_details"
    FOREIGN KEY ("current_inventory_details")
      REFERENCES "current_inventory_details"("current_inventory_details")
);
--  TABLE "payments";
CREATE TABLE "payments" (
  "payment_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "order_count" NUMBER NOT NULL,
  "payment_date" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  "payment_method" VARCHAR2(10) DEFAULT 'Cash' NOT NULL CHECK ("payment_method" IN ('Cash', 'Card', 'Mobile')),
  "pay_amount" NUMBER(10,2),
  "received_amount" NUMBER(10,2),
  "staff_id" NUMBER NOT NULL,
  "discount_id" NUMBER NOT NULL,
  "status" VARCHAR2(10) DEFAULT 'Pending' NOT NULL CHECK ("status" IN ('Pending', 'Cancelled', 'Complete')),
  CONSTRAINT "FK_payments_order_count"
    FOREIGN KEY ("order_count")
      REFERENCES "order_count"("order_count"),
  CONSTRAINT "FK_payments_discount_id"
    FOREIGN KEY ("discount_id")
      REFERENCES "discount"("discount_id"),
  CONSTRAINT "FK_payments_staff_id"
    FOREIGN KEY ("staff_id")
      REFERENCES "staff"("staff_id")
)
PARTITION BY RANGE ("payment_date") INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH')) (
  PARTITION p_initial VALUES LESS THAN (TO_DATE('2024-10-01', 'YYYY-MM-DD'))
);
--  TABLE "Details";
CREATE TABLE "details" (
  "details_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "payment_id" NUMBER NOT NULL,
  "date_time" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  "description" VARCHAR2(50),
  "amount" NUMBER(10,2),
  "debit_credit" VARCHAR2(10),  
  CONSTRAINT "FK_payments_payment_id"
    FOREIGN KEY ("payment_id")
      REFERENCES "payments"("payment_id")
)
PARTITION BY RANGE ("date_time") INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH'))(
    PARTITION P_details VALUES LESS THAN (TO_DATE('2024-10-11', 'YYYY-MM-DD'))
);
--  TABLE "Attachment";
CREATE TABLE "attachment" (
  "attachment_id" NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "details_id" NUMBER NOT NULL,
  "file_path" VARCHAR2(255),
  "upload_at" TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT "FK_Attachment.details_id"
    FOREIGN KEY ("details_id")
      REFERENCES "details"("details_id")
);
--------------- Array Handing ----------
CREATE OR REPLACE PACKAGE arrayData AS
    -- Define collection types for arrays
    TYPE ArrayNUMBER IS TABLE OF NUMBER;          -- Array of numbers
    TYPE ArrayVARCHAR IS TABLE OF VARCHAR2(50);   -- Array of strings with max length 50
    TYPE ArrayBOOLEAN IS TABLE OF NUMBER;         -- Array of 0/1 as boolean (numeric)
    TYPE ArrayDATE IS TABLE OF DATE;              -- Array of DATE values
    TYPE ArrayTIMESTAMP IS TABLE OF TIMESTAMP;    -- Array of TIMESTAMP values
    TYPE ArrayDECIMAL IS TABLE OF NUMBER(10,2);   -- Array of DECIMAL values
END arrayData;
/

--- procedure data ---

create or replace PROCEDURE insert_current_inventory_bulk(
    in_item_name      IN arrayData.ArrayVARCHAR,
    in_description    IN arrayData.ArrayVARCHAR,
    in_unit           IN arrayData.ArrayVARCHAR,
    in_category       IN arrayData.ArrayNUMBER
)
IS
    input_check EXCEPTION;

BEGIN
    -- Loop through the input arrays
    FOR i IN 1 .. in_item_name.COUNT LOOP
        -- Check if the data is valid
        IF in_item_name(i) IS NULL OR in_unit(i) IS NULL THEN
            RAISE input_check;  -- Raise an exception if data is invalid
        ELSE
            -- Insert the data into the inventory table
            INSERT INTO "current_inventory" ("item_name", "description", "unit", "category")
            VALUES (in_item_name(i), in_description(i), in_unit(i), in_category(i));

            -- Output message after insert
            DBMS_OUTPUT.PUT_LINE('Insert successful for item: ' || in_item_name(i));
        END IF;
    END LOOP;

    -- Commit after all inserts are done
    COMMIT;

EXCEPTION
  WHEN input_check THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid input data (e.g., NULL values or negative quantities).');

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);

END;
/

create or replace PROCEDURE add_menu_item (
  p_item_name          IN VARCHAR2,
  p_price              IN NUMBER,
  p_category           IN VARCHAR2,
  p_availability_status IN NUMBER DEFAULT 1
) AS
BEGIN
  INSERT INTO "menu" ("item_name", "price", "category", "availability_status")
  VALUES (p_item_name, p_price, p_category, p_availability_status);

  -- Optional: Commit the transaction if not in a transactional block
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Menu item added successfully: ' || p_item_name);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error adding menu item: ' || SQLERRM);
END;
/
------ JSON Create ---------
create or replace PROCEDURE insert_attachment_json(
        v_json_data IN CLOB
    )
        IS 

    BEGIN
        INSERT INTO "attachment" ("details_id", "file_path")
        SELECT
                JSON_VALUE(ji.value, '$.details_id'),
                JSON_VALUE(ji.value, '$.file_path')
        FROM    JSON_TABLE(JSON_QUERY(V_json_data, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;
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
    create or replace PROCEDURE insert_details_json(
    v_json_data IN CLOB
)
    IS

    BEGIN
        INSERT INTO "details" ("payment_id", "description", "amount", "debit_credit")
        SELECT
                JSON_VALUE(ji.value, '$.payment_id'),
                JSON_VALUE(ji.value, '$.decription'),
                JSON_VALUE(ji.value, '$.amount'),
                JSON_VALUE(ji.value, '$.debit_credit')            
        FROM    JSON_TABLE(JSON_QUERY(v_json_data, '$'), '$[*]' COLUMNS (value  CLOB PATH '$')) ji;
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
create or replace PROCEDURE insert_discount_json(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO "discount" ("discount_name", "discount_rate", "date_effective")
    SELECT 
            JSON_VALUE(ji.value, '$.discount_name'), 
            JSON_VALUE(ji.value, '$.discount_rate'), 
            JSON_VALUE(ji.value, '$.date_effective')
    FROM    JSON_TABLE(JSON_QUERY(v_JSON, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

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

create or replace PROCEDURE insert_menu_json(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO "menu" ("item_name", "price", "category", "availability_status")
    SELECT 
            JSON_VALUE(ji.value, '$.item_name'), 
            JSON_VALUE(ji.value, '$.price'), 
            JSON_VALUE(ji.value, '$.category'),
            JSON_VALUE(ji.value, '$.availability_status') 

    FROM    JSON_TABLE(JSON_QUERY(v_JSON, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

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

create or replace PROCEDURE insert_payment_json(
v_JSON IN CLOB
)
IS

BEGIN
    -- Insert data directly using JSON_TABLE and JSON_VALUE
    INSERT INTO "payments" ("order_count", "payment_method", "pay_amount", "received_amount", "staff_id", "discount_id", "status")
    SELECT 
            JSON_VALUE(ji.value, '$.order_count'), 
            JSON_VALUE(ji.value, '$.payment_method'), 
            JSON_VALUE(ji.value, '$.pay_amount'),
            JSON_VALUE(ji.value, '$.received_amount'),
            JSON_VALUE(ji.value, '$.staff_id'), 
            JSON_VALUE(ji.value, '$.discount_id'), 
            JSON_VALUE(ji.value, '$.status')
    FROM    JSON_TABLE(JSON_QUERY(v_JSON, '$'), '$[*]' COLUMNS (value CLOB PATH '$')) ji;

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

CREATE OR REPLACE PROCEDURE insert_order_items_JSON(
    v_json_data IN CLOB
)
IS
    v_json_array json_array_t := json_array_t (v_json_data);
    v_order_item json_object_t;
    v_item_o json_object_t;
    v_item_a json_array_t;
    v_add_on_a json_array_t;
    v_add_on_o json_object_t;
    v_order_count NUMBER;
BEGIN
    FOR i IN 0..v_json_array.get_size - 1 LOOP
        v_order_item := TREAT (v_json_array.get (i) AS json_object_t);
            --v_order_item := v_json_array.get_object(i);
        v_order_count := v_order_item.get_string('count');
            --v_item_a := v_order_item.get_string('items');
        v_item_a := TREAT (v_order_item.get ('items') AS json_array_t);
        INSERT INTO "order_count"("order_count")
        VALUES (v_order_count);
        
        FOR j IN 0 ..v_item_a.get_size - 1 LOOP
            --v_item_o := v_item_a.get_object(j);
            v_item_o := TREAT (v_item_a.get (j) AS json_object_t);

            INSERT INTO "order_items" ("order_count", "menu_id", "quantity")
            VALUES (v_order_count, v_item_o.get_string('menu'), v_item_o.get_string('quantity'));

            IF v_item_o.has('add_on') THEN 
                v_add_on_a := TREAT (v_item_o.get ('add_on') AS json_array_t); 
                FOR j IN 0 ..v_item_a.get_size - 1 LOOP
                    v_add_on_o := TREAT (v_add_on_a.get ('add_on') AS json_object_t); 
                    INSERT INTO "adds_on" ("order_count", "menu_id", "quantity")
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
CREATE OR REPLACE PROCEDURE insert_inventory_json(
    v_JSON IN CLOB
)
IS
    v_inventory_a json_array_t := json_array_t(v_JSON);
    v_inventory_o json_object_t;
    v_inventory_details_a json_array_t;
    v_inventory_details_o json_object_t;
    v_current_inventory_id NUMBER;

BEGIN

    FOR i IN 0 .. v_inventory_a.get_size -1 LOOP
        --v_inventory_o := v_inventory_a.get_object(i);
        v_inventory_o := TREAT (v_inventory_a.get (i) AS json_object_t);

        INSERT INTO "current_inventory"("item_name", "description", "unit", "category")
        VALUES (v_inventory_o.get_string('item_name'), v_inventory_o.get_string('description'),v_inventory_o.get_string('unit'), v_inventory_o.get_string('category'))
        RETURNING "current_inventory_id" INTO v_current_inventory_id;
        
        --v_inventory_details_a := v_inventory_o.get_array(i);
        v_inventory_details_a := TREAT (v_inventory_o.get ('details') AS json_array_t);

        FOR j IN 0 .. v_inventory_details_a.get_size -1 LOOP
            --v_inventory_details_o := v_inventory_details_a.get_object(j);
            v_inventory_details_o := TREAT (v_inventory_details_o.get (j) AS json_object_t);
            INSERT INTO "current_inventory_details" ("stock_amount", "current_inventory_id")
            VALUES (v_inventory_o.get_string('stock_amount'), v_current_inventory_id);
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

CREATE OR REPLACE PROCEDURE update_inventory_json(
        v_json_data IN CLOB
)
IS 
    v_inventory_a json_array_t := json_array_t(v_json_data);
    v_inventory_o json_object_t;
    v_indetails_a json_array_t;
    v_indetails_o json_object_t;
BEGIN

    FOR i IN 0 .. v_inventory_a.get_size - 1 LOOP
        -- v_inventory_o := v_inventory_a.get_object(i);
        v_inventory_o := TREAT (v_inventory_a.get (i) AS json_object_t);
        UPDATE  "current_inventory"
        SET     "item_name"                 = v_inventory_o.get_string('item_name'),
                "description"               = v_inventory_o.get_string('description'),
                "unit"                      = v_inventory_o.get_string('unit'),
                "category"                  = v_inventory_o.get_string('category'),
                "create_at"                 = v_inventory_o.get_string('create_at')
        WHERE   "current_inventory_id"      = v_inventory_o.get_string('current_inventory_id');
        -- v_indetails_a := v_inventory_o.get_array(i);
        v_indetails_a := TREAT (v_inventory_o.get ('details') AS json_array_t);
        FOR j IN 0 .. v_indetails_a.get_size - 1 LOOP
        -- v_indetails_o := v_indetails_a.get_object(j);
        v_indetails_o := TREAT (v_indetails_a.get (i) AS json_object_t);
            UPDATE  "current_inventory_details"
            SET     "stock_amount"          = v_indetails_o.get_string('stock_amount')
            WHERE  "current_inventory_id"   = v_indetails_o.get_string('current_inventory_id');

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

CREATE OR REPLACE PROCEDURE update_menu_json(
    v_json_data IN CLOB
)

IS
    v_menu_a json_array_t := json_array_t(v_json_data);
    v_menu_o json_object_t;

BEGIN
    FOR i IN 1 .. v_menu_a.get_size LOOP
        -- v_menu_o := v_menu_a.get_object(i);
        v_menu_o := TREAT (v_menu_a.get (i) AS json_object_t);
        UPDATE  "menu"
        SET     "item_name"           = v_menu_o.get_string('item_name'),
                "price"               = v_menu_o.get_string('price'),
                "category"            = v_menu_o.get_string('category'),
                "availability_status"   = v_menu_o.get_string('availability_status')        
        WHERE   "menu_id"             = v_menu_o.get_string('menu_id');
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

CREATE OR REPLACE PROCEDURE update_discount_json(
    v_json_data IN CLOB
)

IS
    v_discount_a json_array_t := json_array_t(v_json_data);
    v_discount_o json_object_t;

BEGIN
    FOR i IN 1 .. v_discount_a.get_size LOOP
        -- v_discount_o := v_discount_a.get_object(i);
        v_discount_o := TREAT (v_discount_a.get (i) AS json_object_t);
        UPDATE  "discount"
        SET     "discount_name"       = v_discount_o.get_string('discount_name'),
                "discount_rate"       = v_discount_o.get_string('discount_rate'),
                "date_effective"      = v_discount_o.get_string('date_effective')
        WHERE   "discount_id"         = v_discount_o.get_string('discount_id');
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

CREATE OR REPLACE PROCEDURE update_staff_json(
    v_json_data IN CLOB
)

IS
    v_staff_a json_array_t := json_array_t(v_json_data);
    v_staff_o json_object_t;

BEGIN
    FOR i IN 1 .. v_staff_a.get_size LOOP
        -- v_staff_o := v_staff_a.get_object(i);
        v_staff_o := TREAT (v_staff_a.get (i) AS json_object_t);
        UPDATE  "staff"
        SET     "first"       = v_staff_o.get_string('first'),
                "last"        = v_staff_o.get_string('last'),
                "position"    = v_staff_o.get_string('position'),
                "salary"      = v_staff_o.get_string('salary'),
                "hire_date"   = v_staff_o.get_string('hire_date'),
                "email"       = v_staff_o.get_string('email')
        WHERE   "staff_id"    = v_staff_o.get_string('staff_id');
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

--------------------  Trigger ------------------------
CREATE OR REPLACE TRIGGER trigger_after_insert_payments
AFTER INSERT ON "payments"
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN

   SELECT COUNT(*)
    INTO v_exists
    FROM "order_items" oi
    WHERE oi."order_count" = :NEW."order_count";

    IF v_exists > 0 THEN
        INSERT INTO "inventory_transaction" ("stock_quantity", "action", "current_inventory_details")
        SELECT 
            (oi."quantity" * oid."amount") AS stock_quantity,
            'Used' AS action,
            oid."current_inventory_id"
        FROM "order_items" oi
        JOIN "menu" m ON m."menu_id" = oi."menu_id"
        JOIN "per_single_serving" oid ON m."menu_id" = oid."menu_id"
        WHERE oi."order_count" = :NEW."order_count";
    END IF;

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No data found for today.');
END;
/