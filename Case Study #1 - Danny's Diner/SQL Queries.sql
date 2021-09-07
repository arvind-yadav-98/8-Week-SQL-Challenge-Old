CREATE TABLE SALES (
  CUSTOMER_ID VARCHAR(1),
  ORDER_DATE DATE,
  PRODUCT_ID INTEGER
);

INSERT INTO SALES VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  PRODUCT_ID INTEGER,
  PRODUCT_NAME VARCHAR(5),
  PRICE INTEGER
);

INSERT INTO MENU VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE MEMBERS (
  CUSTOMER_ID VARCHAR(1),
  JOIN_DATE DATE
);

INSERT INTO MEMBERS VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
 /* Que.1  What is the total amount each customer spent at the restaurant?  */ 
 
 SELECT  S.CUSTOMER_ID, SUM(M.PRICE) FROM SALES S 
 JOIN MENU M ON 
 S.PRODUCT_ID = M.PRODUCT_ID
 GROUP BY  S.CUSTOMER_ID;
 
 
 /* Que.2  How many days has each customer visited the restaurant?  */
 
 SELECT S.CUSTOMER_ID, COUNT(DISTINCT(S.ORDER_DATE))
 FROM SALES S 
 GROUP BY S.CUSTOMER_ID;
 
 
 /* Que.3  What was the first item from the menu purchased by each customer?  */
 
 SELECT NT.CUSTOMER_ID, NT.PRODUCT_ID FROM
    (SELECT *,
     ROW_NUMBER() OVER(PARTITION  BY S. CUSTOMER_ID) AS RK 
     FROM SALES S ) NT 
 WHERE NT.RK = 1;
 
 
 /* Que.4  What is the most purchased item on the menu and how many times was it purchased by all customers?  */
 
 SELECT S.PRODUCT_ID, COUNT(*) AS TOTALSALES
 FROM SALES S 
 GROUP BY S.PRODUCT_ID
 ORDER BY TOTALSALES DESC LIMIT 1;
 
 
 /* Que.5  Which item was the most popular for each customer?  */
 
WITH CTE_POPULAR AS
 (SELECT S.CUSTOMER_ID, M.PRODUCT_NAME, COUNT(*) AS PRODUCTSALES,
 DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY COUNT(*) DESC) AS RK 
 FROM SALES S 
 JOIN MENU M ON
 S.PRODUCT_ID = M.PRODUCT_ID
 GROUP BY S.CUSTOMER_ID, M.PRODUCT_NAME )

 SELECT NT.CUSTOMER_ID, NT.PRODUCT_NAME, NT.PRODUCTSALES  FROM CTE_POPULAR NT  
 WHERE NT.RK = 1 ;
 
 
 /* Que.6  Which item was purchased first by the customer after they became a member?  */ 
 
 WITH CTE_AFTER_MEMBER AS
(SELECT S.CUSTOMER_ID, ME.PRODUCT_NAME, S.ORDER_DATE,
 DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RK 
 FROM SALES S 
 JOIN MEMBERS M ON 
 S.CUSTOMER_ID = M.CUSTOMER_ID
 JOIN MENU ME ON
 S.PRODUCT_ID = ME.PRODUCT_ID
 WHERE S.ORDER_DATE >= M.JOIN_DATE)
 
 SELECT CUSTOMER_ID, PRODUCT_NAME, ORDER_DATE FROM CTE_AFTER_MEMBER
 WHERE RK = 1;
 
 
 /* Que.7  Which item was purchased just before the customer became a member?  */
 
 WITH CTE_BEFORE_MEMBER AS
(SELECT S.CUSTOMER_ID, ME.PRODUCT_NAME, S.ORDER_DATE,
 DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE DESC) AS RK 
 FROM SALES S 
 JOIN MEMBERS M ON 
 S.CUSTOMER_ID = M.CUSTOMER_ID
 JOIN MENU ME ON
 S.PRODUCT_ID = ME.PRODUCT_ID
 WHERE S.ORDER_DATE < M.JOIN_DATE)
 
 SELECT CUSTOMER_ID, PRODUCT_NAME, ORDER_DATE FROM CTE_BEFORE_MEMBER
 WHERE RK = 1;
 
 
 /* Que.8  What is the total items and amount spent for each member before they became a member?  */
 
 SELECT S.CUSTOMER_ID, COUNT(*), SUM(PRICE) FROM SALES S 
 JOIN MEMBERS M ON 
 S.CUSTOMER_ID = M.CUSTOMER_ID
 JOIN MENU ME ON
 S.PRODUCT_ID = ME.PRODUCT_ID
 WHERE S.ORDER_DATE < M.JOIN_DATE
 GROUP BY S.CUSTOMER_ID;
 
 
 /* Que.9  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?  */
  
SELECT NT.CUSTOMER_ID, SUM(NT.POINTS) FROM 
(SELECT S.CUSTOMER_ID,
 CASE 
     WHEN M.PRODUCT_NAME = 'sushi' THEN (M.PRICE)*20
     ELSE (M.PRICE)*10 
 END AS POINTS
 FROM SALES S 
 JOIN MENU M ON
 S.PRODUCT_ID = M.PRODUCT_ID ) NT
 GROUP BY NT.CUSTOMER_ID;  
 
 
/* Que.10  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
   how many points do customer A and B have at the end of January? */
   
WITH CTE_DATE AS (
SELECT *,
  DATE_ADD(JOIN_DATE, INTERVAL 6 DAY) AS VALID_DATE, 
  LAST_DAY('2021-01-31') AS MONTH_LAST_DATE 
FROM MEMBERS AS M
)

SELECT D.CUSTOMER_ID, S.ORDER_DATE, D.JOIN_DATE, 
 D.VALID_DATE, D.MONTH_LAST_DATE, M.PRODUCT_NAME, M.PRICE,
 SUM(CASE
  WHEN M.PRODUCT_NAME = 'sushi' THEN (M.PRICE)*20
  WHEN S.ORDER_DATE BETWEEN D.JOIN_DATE AND D.VALID_DATE THEN (M.PRICE)*20
  ELSE (M.PRICE)*10
  END) AS points
FROM CTE_DATE AS D
JOIN SALES AS S
 ON D.CUSTOMER_ID = S.CUSTOMER_ID
JOIN MENU AS M
 ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE S.ORDER_DATE < D.MONTH_LAST_DATE
GROUP BY D.CUSTOMER_ID, S.ORDER_DATE, D.JOIN_DATE, 
 D.VALID_DATE, D.MONTH_LAST_DATE, M.PRODUCT_NAME, M.PRICE ;
 
 
 
/* BONUS QUESTIONS */



/* Que.1  Join All The Things
          Recreate the table with: customer_id, order_date, product_name, price, member (Y/N) */
          
SELECT S.CUSTOMER_ID, S.ORDER_DATE, M.PRODUCT_NAME, M.PRICE, 
CASE 
    WHEN (S.ORDER_DATE < MM.JOIN_DATE)  OR (MM.JOIN_DATE IS NULL) THEN 'N'
    ELSE 'Y'
END AS MEMBER
FROM SALES S
JOIN MENU M ON
S.PRODUCT_ID = M.PRODUCT_ID
LEFT JOIN MEMBERS MM ON
S.CUSTOMER_ID = MM.CUSTOMER_ID;


/* Que.2  Rank All The Things 
          Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123) */
          
WITH CTE_TABLE AS (
SELECT S.CUSTOMER_ID, S.ORDER_DATE, M.PRODUCT_NAME, M.PRICE, 
CASE 
    WHEN (S.ORDER_DATE < MM.JOIN_DATE)  OR (MM.JOIN_DATE IS NULL) THEN 'N'
    ELSE 'Y'
END AS MEMBER
FROM SALES S
JOIN MENU M ON
S.PRODUCT_ID = M.PRODUCT_ID
LEFT JOIN MEMBERS MM ON
S.CUSTOMER_ID = MM.CUSTOMER_ID
)

SELECT *, 
CASE 
    WHEN MEMBER = 'Y' THEN DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID,MEMBER ORDER BY ORDER_DATE)  
    ELSE NULL
    END AS RANKING    
FROM CTE_TABLE;