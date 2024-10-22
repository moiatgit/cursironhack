
-- Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una
-- consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento
-- para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.

SELECT Title, FirstName, LastName, dateOfBirth from customer;

-- Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una
-- consulta SQL que muestre el número de clientes en cada grupo de clientes
-- (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3
-- Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?

SELECT CustomerGroup, count(*) FROM customer GROUP BY CustomerGroup;

-- Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista
-- completa de todos los datos para esos clientes en la tabla de clientes pero
-- necesito añadir el código de moneda de cada jugador para que pueda enviar la
-- oferta correcta en la moneda correcta. Nota que el código de moneda no
-- existe en la tabla de clientes sino en la tabla de cuentas. Por favor,
-- escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un
-- conjunto de datos mucho más grande?

SELECT customer.*, account.CurrencyCode FROM customer JOIN account ON customer.CustId = account.CustId;


-- Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe
-- resumen que muestre, por producto y por día, cuánto dinero se ha apostado en
-- un producto particular. TEN EN CUENTA que las transacciones están
-- almacenadas en la tabla de apuestas y hay un código de producto en esa tabla
-- que se requiere buscar (classid & categoryid) para determinar a qué familia
-- de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el
-- informe. Si imaginas que esto fue un conjunto de datos mucho más grande en
-- Excel, ¿cómo proporcionarías este informe en Excel?

-- Nota: Dado que el enunciado parece requerir la clave doble, la he incluido
-- en la consulta. Sin embargo, una inspección a los datos muestra que CLASSID
-- ya es clave por si sola y CATEGORYID es redundante como clave.

SELECT product.CLASSID, product.CATEGORYID, betting.BetDate, sum(Bet_amt)
FROM product JOIN betting ON product.CLASSID = betting.ClassId AND product.CATEGORYID = betting.CategoryId
GROUP BY product.CLASSID, product.CATEGORYID, betting.BetDate;


-- Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente
-- de producto, ahora él me ha enviado un correo electrónico y quiere que se
-- cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma
-- las transacciones que ocurrieron el 1 de noviembre o después y solo quiere
-- ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo
-- que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?

SELECT product.CLASSID, product.CATEGORYID, sum(Bet_amt)
FROM product JOIN betting ON product.CLASSID = betting.ClassId AND product.CATEGORYID = betting.CategoryId
WHERE BetDate >= '2012-11-01' AND product.product = 'Sportsbook'
GROUP BY product.CLASSID, product.CATEGORYID;


-- Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo
-- informe a su director y ahora él también quiere una versión diferente de
-- este informe. Esta vez, quiere todos los productos pero divididos por el
-- código de moneda y el grupo de clientes del cliente, en lugar de por día y
-- producto. También le gustaría solo transacciones que ocurrieron después del
-- 1 de diciembre. Por favor, escribe el código SQL que hará esto.

-- La consulta a resolver: total apuestas posteriores al 1 de diciembre por
-- cada producto de cada moneda de cada grupo de cliente 

SELECT CurrencyCode, CustomerGroup, product.product, sum(Bet_amt)
FROM customer JOIN account ON customer.CustId = account.CustId
              JOIN betting ON account.accountNo = betting.AccountNo
              JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
GROUP BY CurrencyCode, CustomerGroup, product.Product;



-- Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los
-- jugadores independientemente de si han hecho algo en el marco de tiempo
-- completo o no. En nuestro ejemplo, es posible que no todos los jugadores
-- hayan estado activos. Por favor, escribe una consulta SQL que muestre a
-- todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de
-- apuesta para el período completo de noviembre.

SELECT Title, FirstName, LastName, sum(Bet_amt)
FROM customer JOIN account ON customer.CustId = account.CustId
              JOIN betting ON account.accountNo = betting.AccountNo
where MONTH(BetDate) = '11'
GROUP BY account.accountNo;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de
-- jugadores que juegan más de un producto. ¿Puedes por favor escribir 2
-- consultas, una que muestre el número de productos por jugador y otra que
-- muestre jugadores que juegan tanto en Sportsbook como en Vegas?


-- Priemra consulta
select Title, FirstName, LastName, count(product)
FROM (SELECT DISTINCT customer.CustId, Title, FirstName, LastName, product.product
      FROM customer JOIN account ON customer.CustId = account.CustId
                    JOIN betting ON account.accountNo = betting.AccountNo
                    JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
    ) as customerproduct
GROUP BY CustId;


-- Segunda consulta
CREATE OR REPLACE VIEW customer_product AS
    SELECT DISTINCT customer.CustId, Title, FirstName, LastName, product.product
    FROM customer JOIN account ON customer.CustId = account.CustId
                  JOIN betting ON account.accountNo = betting.AccountNo
                  JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
    WHERE product.product in ('Sportsbook', 'Vegas');

SELECT Title, FirstName, LastName, count(product) as num_products
FROM customer_product
GROUP BY CustId
HAVING num_products = 2;

DROP VIEW customer_product;


-- Intentemos una versión con CTE (Common Table Expression) o tablas temporales
WITH customer_product AS (
    SELECT DISTINCT customer.CustId, Title, FirstName, LastName, product.product
    FROM customer JOIN account ON customer.CustId = account.CustId
                  JOIN betting ON account.accountNo = betting.AccountNo
                  JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
    WHERE product.product in ('Sportsbook', 'Vegas')
)
SELECT Title, FirstName, LastName, count(product) as num_products
FROM customer_product
GROUP BY CustId
HAVING num_products = 2;



-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo
-- juegan un producto, por favor escribe código SQL que muestre a los jugadores
-- que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada
-- jugador y la suma de sus apuestas para ambos productos.


WITH customer_product AS (
    SELECT DISTINCT customer.CustId, Title, FirstName, LastName, product.product
    FROM customer JOIN account ON customer.CustId = account.CustId
                  JOIN betting ON account.accountNo = betting.AccountNo
                  JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
)
SELECT Title, FirstName, LastName, count(product) as num_products
FROM customer_product
GROUP BY CustId
HAVING num_products = 1;


-- Pregunta 10: La última pregunta requiere que calculemos y determinemos el
-- producto favorito de un jugador. Esto se puede determinar por la mayor
-- cantidad de dinero apostado. Por favor, escribe una consulta que muestre el
-- producto favorito de cada jugador

WITH customer_product_amount AS (
    SELECT customer.CustId, Title, FirstName, LastName, product.product, sum(Bet_Amt) AS amount
    FROM customer JOIN account ON customer.CustId = account.CustId
                JOIN betting ON account.accountNo = betting.AccountNo
                JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
    GROUP BY customer.CustId, product.product
),
    customer_product_max_amount AS (
    SELECT CustId, Title, FirstName, LastName, MAX(amount) AS max_amount_in_product
    FROM customer_product_amount
    GROUP BY CustId
)
SELECT a.Title, a.FirstName, a.LastName, a.product, max_amount_in_product
FROM customer_product_amount AS a JOIN customer_product_max_amount AS b ON a.CustId = b.CustId AND amount = max_amount_in_product;

-- Intentemos una versión usando RANK

WITH customer_product_amount AS (
    SELECT customer.CustId, Title, FirstName, LastName, product.product, sum(Bet_Amt) AS amount
    FROM customer JOIN account ON customer.CustId = account.CustId
                JOIN betting ON account.accountNo = betting.AccountNo
                JOIN product ON betting.ClassId = product.CLASSID and betting.CategoryId = product.CATEGORYID
    GROUP BY customer.CustId, product.product
)
SELECT Title, FirstName, LastName, product
FROM (
    SELECT Title, FirstName, LastName, product, amount,
       RANK() OVER (PARTITION BY CustId ORDER BY amount DESC) AS ranking
    FROM customer_product_amount
) AS ranked_results
WHERE ranking = 1;


-- Mirando los datos abstractos en la pestaña "Student_School" en la hoja de
-- cálculo de Excel, por favor responde las siguientes preguntas:


-- Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes
-- basándose en el GPA

SELECT student_name, RANK() OVER (ORDER BY GPA DESC) AS ranking
FROM student
LIMIT 5;


-- Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en
-- cada escuela. (¡una escuela debería estar en la salida incluso si no tiene
    -- estudiantes!)

SELECT school_name, COUNT(student_id)
FROM school LEFT JOIN student ON school.school_id = student.school_id
GROUP BY school.school_id;

-- Pregunta 13: Escribe una consulta que devuelva los nombres de los 3
-- estudiantes con el GPA más alto de cada universidad.

SELECT *
FROM 
    (SELECT school_name, student_name, GPA,
            RANK() OVER (PARTITION BY school.school_id ORDER BY GPA DESC) AS ranking
    FROM school JOIN student ON school.school_id = student.school_id) AS ranked_schools
WHERE ranking <= 3;

