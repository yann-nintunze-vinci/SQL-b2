--2.a.ii
--1
SELECT a.au_id, a.au_lname
FROM authors a
WHERE a.city = 'Oakland';

--2
SELECT a.au_id, a.au_lname, a.address
FROM authors a
WHERE a.au_fname
          LIKE 'A%';

--3
SELECT a.au_id, a.au_lname, a.address, a.city, a.state, a.country
FROM authors a
WHERE a.phone IS NULL;

--4
SELECT a.au_lname, a.au_fname
FROM authors a
WHERE a.state = 'CA'
  AND a.phone NOT LIKE '415%';

--5
SELECT a.*
FROM authors a
WHERE a.country IN ('BEL', 'NED', 'LUX');

--6
SELECT DISTINCT t.pub_id
FROM titles t
WHERE t.type = 'psychology';

--7
SELECT DISTINCT t.pub_id
FROM titles t
WHERE t.type = 'psychology'
  AND t.price BETWEEN 10 AND 25;

--8
SELECT DISTINCT a.city
FROM authors a
WHERE a.state = 'CA'
  AND (a.au_fname = 'Albert' OR a.au_lname LIKE '%er');

--9
SELECT DISTINCT a.state, a.country
FROM authors a
WHERE a.state IS NOT NULL
  AND a.country != 'USA';

--10
SELECT DISTINCT t.type
FROM titles t
WHERE t.price < 15;

--2.b.iv
--1
SELECT t.title, t.price, p.pub_name
FROM titles t,
     publishers p
WHERE p.pub_id = t.pub_id;

--2
SELECT t.title, t.price, p.pub_name
FROM titles t,
     publishers p
WHERE p.pub_id = t.pub_id
  AND t.type = 'psychology';

--3
SELECT DISTINCT a.au_fname, a.au_lname
FROM authors a,
     titleauthor ta
WHERE ta.au_id = a.au_id;

--4
SELECT DISTINCT a.state
FROM authors a,
     titleauthor ta
WHERE ta.au_id = a.au_id;

--5
SELECT DISTINCT s.stor_name, s.stor_address, s.city, s.state, s.country
FROM stores s,
     sales sa
WHERE sa.stor_id = s.stor_id
  AND date_part('month', sa.date) = '11'
  AND date_part('year', sa.date) = '1991';

--6
SELECT t.title, t.price, t.total_sales
FROM titles t,
     publishers p
WHERE p.pub_id = t.pub_id
  AND t.type = 'psychology'
  AND p.pub_name NOT LIKE 'Algo%'
  AND t.price < 20;

--7
SELECT DISTINCT t.title
FROM titles t,
     titleauthor ta,
     authors a
WHERE ta.au_id = a.au_id
  AND ta.title_id = t.title_id
  AND a.state = 'CA';

--8
SELECT DISTINCT a.au_lname, a.au_fname
FROM authors a,
     titleauthor ta,
     publishers p,
     titles t
WHERE ta.au_id = a.au_id
  AND ta.title_id = t.title_id
  AND p.pub_id = t.pub_id
  AND p.state = 'CA';

--9
SELECT DISTINCT a.au_lname, a.au_fname
FROM authors a,
     titles t,
     titleauthor ta,
     publishers p
WHERE ta.title_id = t.title_id
  AND ta.au_id = a.au_id
  AND t.pub_id = p.pub_id
  AND p.state = a.state;

--10
SELECT DISTINCT p.pub_id, p.pub_name, p.city, p.state
FROM publishers p,
     titles t,
     salesdetail sd,
     sales sa
WHERE t.pub_id = p.pub_id
  AND sd.title_id = t.title_id
  AND sd.ord_num = sa.ord_num
  AND sd.stor_id = sa.stor_id
  AND sa.date BETWEEN '1990-11-01' AND '1991-03-01';

--11
SELECT DISTINCT s.stor_id, s.stor_name, s.stor_address, s.city, s.state, s.country
FROM stores s,
     salesdetail sd,
     titles t
WHERE s.stor_id = sd.stor_id
  AND sd.title_id = t.title_id
  AND t.title SIMILAR TO '%(cook|Cook)%';

--12
SELECT t1.title_id, t1.title, t2.title_id, t2.title
FROM titles t1,
     titles t2
WHERE t1.pub_id = t2.pub_id
  AND t1.pubdate = t2.pubdate
  AND t1.title_id < t2.title_id;

--13
SELECT a.au_id, a.au_lname, a.au_fname
FROM authors a,
     titleauthor ta,
     titles t
WHERE a.au_id = ta.au_id
  AND ta.title_id = t.title_id
GROUP BY a.au_id, a.au_lname, a.au_fname
HAVING COUNT(DISTINCT t.pub_id) > 1;

--14
SELECT DISTINCT t.title_id, t.title, t.type, t.price
FROM titles t,
     salesdetail sd,
     sales sa
WHERE sd.title_id = t.title_id
  AND sd.ord_num = sa.ord_num
  AND sd.stor_id = sa.stor_id
  AND t.pubdate > sa.date;

--15
SELECT DISTINCT s.stor_id, s.stor_name, s.stor_address
FROM stores s,
     salesdetail sd,
     titleauthor ta,
     authors a
WHERE sd.stor_id = s.stor_id
  AND sd.title_id = ta.title_id
  AND ta.au_id = a.au_id
  AND a.au_fname = 'Anne'
  AND a.au_lname = 'Ringer';

--16
SELECT DISTINCT a.state
FROM authors a,
     titleauthor ta,
     salesdetail sd,
     sales sa,
     stores s
WHERE ta.au_id = a.au_id
  AND ta.title_id = sd.title_id
  AND sd.ord_num = sa.ord_num
  AND sd.stor_id = sa.stor_id
  AND sa.stor_id = s.stor_id
  AND s.state = 'CA'
  AND a.state IS NOT NULL
  AND date_part('month', sa.date) = '02'
  AND date_part('year', sa.date) = '1991';

--17
SELECT DISTINCT s1.stor_name, s2.stor_name
FROM stores s1,
     salesdetail sd1,
     titleauthor ta1,
     stores s2,
     salesdetail sd2,
     titleauthor ta2
WHERE s1.stor_id = sd1.stor_id
  AND sd1.title_id = ta1.title_id
  AND ta1.au_id = ta2.au_id
  AND ta2.title_id = sd2.title_id
  AND s2.stor_id = sd2.stor_id
  AND s1.state = s2.state
  AND s1.stor_id < s2.stor_id;

--18
SELECT a1.au_id ,a1.au_fname, a1.au_lname, a2.au_id, a2.au_fname, a2.au_lname
FROM titleauthor ta1,
     authors a1,
     titleauthor ta2,
     authors a2
WHERE ta1.au_id = a1.au_id
  AND ta2.au_id = a2.au_id
  AND ta1.title_id = ta2.title_id
  AND a1.au_id < a2.au_id;

--19
SELECT t.title,
       s.stor_name,
       t.price,
       sd.qty,
       SUM(sd.qty * t.price)          AS montant_total,
       SUM((sd.qty * t.price) * 0.02) AS taxe_sur_CA
FROM titles t,
     salesdetail sd,
     stores s
WHERE sd.title_id = t.title_id
  AND sd.stor_id = s.stor_id
GROUP BY t.title, s.stor_name, t.price, sd.qty;