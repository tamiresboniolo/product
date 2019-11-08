/*Author: Tamires D Boniolo*/

/*1. Write a script that creates and calls a stored procedure named test. This stored procedure should declare a variable and set it to the count of all products in the Products table. If the count is greater than or equal to 7, the stored procedure should display a message that says, “The number of products is greater than or equal to 7”. Otherwise, it should say, “The number of products is less than 7”. */
DROP PROCEDURE IF EXISTS test;
DELIMITER // 
CREATE PROCEDURE test()  
BEGIN
	DECLARE product_count INT;
	SELECT COUNT(product_count)  
	INTO product_count
	FROM products;
IF product_count >= 7 THEN
	SELECT 'The number of products is greater than or equal to 7' AS message;
ELSE
	SELECT 'The number of products is less than 7' AS message; 
END IF;
END//

DELIMITER ; --need to have a space between the word and the semicolon to work
CALL test();


/*2. Write a script that creates and calls a stored procedure named test. This stored procedure should use two variables to store (1) the count of all of the products in the Products table and (2) the average list price for those products. If the product count is greater than or equal to 7, the stored procedure should display a result set that displays the values of both variables. Otherwise, the procedure should display a result set that displays a message that says, “The number of products is less than 7”.*/
DROP PROCEDURE IF EXISTS test;
DELIMITER //
 
CREATE PROCEDURE test()
BEGIN
    DECLARE product_count INT;
    DECLARE average_price DECIMAL(9,2);
     
    SELECT COUNT(product_id), AVG(list_price)
    INTO product_count, average_price
    FROM products;
     
    IF product_count >= 7 THEN
        SELECT product_count, average_price;
    ELSE
        SELECT 'The number of products is less than 7' AS message;
    END IF;
END//
 
DELIMITER ;
CALL test();
		
/*3 Write a script that creates and calls a stored procedure named test. This procedure should calculate the common factors between 10 and 20. To find a common factor, you can use the modulo operator (%) to check whether a number can be evenly divided into both numbers. Then, this procedure should display a string that displays the common factors like this: 
Common factors of 10 and 20: 1 2 5 */
DROP PROCEDURE IF EXISTS test; 
DELIMITER //
 
CREATE PROCEDURE test()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE divisor_found TINYINT DEFAULT FALSE;
    DECLARE s VARCHAR(400) DEFAULT 'Common factors of 10 and 20:';
    WHILE i < 10 DO
        IF 10 % i = 0 AND 20 % i = 0 THEN
            SET s = CONCAT(s, i, ' ');  
            SET divisor_found = TRUE;        
        END IF; 
        SET i = i + 1;
    END WHILE;	
    IF divisor_found = TRUE THEN
        SELECT s AS message;
    ELSE
        SELECT 'Did not find common factors.' AS message;
    END IF; 
END//
 
DELIMITER ;
CALL test();

/*4. Write a script that creates and calls a stored procedure named test. This stored procedure should create a cursor for a result set that consists of the product_name and list_price columns for each product with a list price that’s greater than $700. The rows in this result set should be sorted in descending sequence by list price. Then, the procedure should display a string variable that includes the product_name and list price for each product so it looks something like this:
"Gibson SG","2517.00"|"Gibson Les Paul","1199.00"|
Here, each value is enclosed in double quotes ("), each column is separated by a comma (,) and each row is separated by a pipe character (|).*/
DROP PROCEDURE IF EXISTS test; 
DELIMITER //
 
CREATE PROCEDURE test()
BEGIN
    DECLARE product_name_v VARCHAR(50);
    DECLARE list_price_v INT; 
    DECLARE r VARCHAR(400) DEFAULT '';
    DECLARE row_not_found INT DEFAULT FALSE; 
    DECLARE product_cursor CURSOR FOR
        SELECT product_name, list_price 
        FROM products
        WHERE list_price > 700
        ORDER BY list_price DESC;
 
    BEGIN
        DECLARE EXIT HANDLER FOR NOT FOUND
            SET row_not_found = TRUE; 
        OPEN product_cursor;         
        WHILE row_not_found = FALSE DO
            FETCH product_cursor 
            INTO product_name_v, list_price_v; 
				SET r = CONCAT(r, '"', product_name_v, '", ',list_price_v, ' | ');
        END WHILE;
    END; 
    CLOSE product_cursor; 
    SELECT r AS message;
END//
 
DELIMITER ;
CALL test();

/*5.Write a script that creates and calls a stored procedure named test. This procedure should attempt to insert a new category named “Guitars” into the Categories table. If the insert is successful, the procedure should display this message:
1 row was inserted.
If the update is unsuccessful, the procedure should display this message: Row was not inserted - duplicate entry.*/
DROP PROCEDURE IF EXISTS test; 
DELIMITER //
 
CREATE PROCEDURE test()
BEGIN
    DECLARE category_add TINYINT DEFAULT FALSE; 
    DECLARE CONTINUE HANDLER FOR 1062
        SET category_add = TRUE; 
    INSERT INTO categories 
    VALUES (1, 'Guitars');   
    IF category_add = TRUE THEN
        SELECT 'row was not inserted - duplicate entry' AS message;  
    ELSE
        SELECT '1 row was inserted' AS message;   
    END IF; 
END//
 
DELIMITER ; 
CALL test();


/*
*SECOND PART 
*Chapter 14 and 15
*/


/*1.Write a script that creates and calls a stored procedure named insert_category. First, code a statement that creates a procedure that adds a new row to the Categories table. To do that, this procedure should have one parameter for the category name.
Code at least two CALL statements that test this procedure. (Note that this table doesn’t allow duplicate category names.)*/
 
DROP PROCEDURE IF EXISTS insert_category; 
DELIMITER //
 
CREATE PROCEDURE insert_category (category_name_v VARCHAR(400))
BEGIN     
    INSERT INTO categories (category_name)
    VALUES (category_name_v); 
END//
 
DELIMITER ;
CALL insert_category("Bohm");
CALL insert_category("Guitars"); --Guitars already exist, so it will generate an error

/*2.Write a script that creates and calls a stored function named discount_price that calculates the discount price of an item in the Order_Items table (discount amount subtracted from item price). To do that, this function should accept one parameter for the item ID, and it should return the value of the discount price for that item.*/ 
DROP FUNCTION IF EXISTS discount_price; 
DELIMITER //
 
CREATE FUNCTION discount_price(item_id_i INT)RETURNS DECIMAL(9,2)
BEGIN
    DECLARE discount_price_v DECIMAL(9,2); 
    SELECT item_price - discount_amount
    INTO discount_price_v
    FROM order_items
    WHERE item_id = item_id_i;     
    RETURN(discount_price_v);
END//
 
DELIMITER ;
SELECT discount_price(5) AS "Discount Price"; --accept one parameter

/*3.Write a script that creates and calls a stored function named item_total that calculates the total amount of an item in the Order_Items table (discount price multiplied by quantity). To do that, this function should accept one parameter for the item ID, it should use the discount_price function that you created in assignment 2, and it should return the value of the total for that item.*/
DROP FUNCTION IF EXISTS item_total; 
DELIMITER //
 
CREATE FUNCTION item_total(item_id_i INT) RETURNS DECIMAL(9,2)
BEGIN
    DECLARE total_price DECIMAL(9,2);     
    SELECT quantity * discount_price(item_id_i)
    INTO total_price
    FROM order_items
    WHERE item_id = item_id_i;     
    RETURN(total_price);
END//
 
DELIMITER ;
SELECT item_total(5) AS 'Item Total'; --accept one parameter



/*4.Write a script that creates and calls a stored procedure named update_product_discount that updates the discount_percent column in the Products table. This procedure should have one parameter for the product ID and another for the discount percent.
If the value for the discount_percent column is a negative number, the stored procedure should signal state indicating that the value for this column must be a positive number.
Code at least two CALL statements that test this procedure.*/
DROP PROCEDURE IF EXISTS update_product_discount; 
DELIMITER //
 
CREATE PROCEDURE update_product_discount(product_id_i INT, discount_percent_i DECIMAL(9,2))
BEGIN
    IF discount_percent_i < 0 THEN
        SIGNAL SQLSTATE '22003'
            SET MESSAGE_TEXT = 'product percent must be a positive number!',
            MYSQL_ERRNO = 1264;
    END IF;
     
    IF product_id_i IS NULL THEN
        SET product_id_i = 1;
    END IF;
 
    IF discount_percent_i IS NULL THEN
        SET discount_percent_i = 100;
    END IF;
 
    UPDATE products
    SET discount_percent = discount_percent_i
    WHERE product_id = product_id_i; 
END//
 
DELIMITER ; 
CALL update_product_discount(5, 83);
CALL update_product_discount(10, -2); --error message 
CALL update_product_discount(1, 0);



/*5.Write a script that creates and calls a stored procedure named test. This procedure should include two SQL statements coded as a transaction to delete the row with a customer ID of 8 from the Customers table. To do this, you must first delete all addresses for that order from the Addresses table.
If these statements execute successfully, commit the changes. Otherwise, roll back the changes. */
DROP PROCEDURE IF EXISTS test; 
DELIMITER //
 
CREATE PROCEDURE test()
BEGIN
    DECLARE sql_error INT DEFAULT FALSE;   
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET sql_error = TRUE; 
    START TRANSACTION;
     
    DELETE FROM addresses
    WHERE customer_id = 8; 
    DELETE FROM customers
    WHERE customer_id = 8; 
    COMMIT;
   
    IF sql_error = FALSE THEN
        COMMIT;
        SELECT 'Statements executed successfully! The transaction was commit.';
    ELSE
        ROLLBACK;
        SELECT 'The transaction was roll back.';
    END IF;
END//
 
DELIMITER ; 
CALL test();


