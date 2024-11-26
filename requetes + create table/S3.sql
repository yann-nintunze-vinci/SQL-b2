--2.e.iv
--1
SELECT ti.title_id, ti.title, ti.price, ti.type
FROM titles ti,
     publishers p
WHERE ti.pub_id = p.pub_id
  AND p.pub_name = 'Algodata Infosystems'
  AND ti.price = (SELECT MAX(ti2.price)
                  FROM titles ti2
                  WHERE ti2.pub_id = p.pub_id);

--3
SELECT ti.title_id, ti.title, ti.price, ti.type
FROM titles ti
WHERE ti.price > (SELECT AVG(ti2.price) * 1.5
                  FROM titles ti2
                  WHERE ti2.type = ti.type);

--5
SELECT p.pub_id, p.pub_name
FROM publishers p
WHERE p.pub_id NOT IN (SELECT DISTINCT ti.pub_id
                       FROM titles ti);

--6
SELECT p.pub_id, p.pub_name
FROM publishers p,
     titles ti
WHERE p.pub_id = ti.title_id
GROUP BY p.pub_id, p.pub_name
HAVING COUNT(ti.title_id) >= ALL (SELECT COUNT(ti2.title_id)
                                  FROM titles ti2);

--7
SELECT p.pub_id, p.pub_name
FROM publishers p
WHERE p.pub_id NOT IN (SELECT t.pub_id
                       FROM salesdetail sd,
                            titles t
                       WHERE t.title_id = sd.title_id);

--8
SELECT DISTINCT ti.title_id, ti.title, ti.type
FROM titles ti,
     titleauthor ta,
     authors au,
     publishers p
WHERE ti.title_id = ta.title_id
  AND au.au_id = ta.au_id
  AND ti.pub_id = p.pub_id
  AND au.state = 'CA'
  AND p.state = 'CA'
  AND NOT EXISTS(SELECT *
                 FROM stores st,
                      salesdetail sd
                 WHERE st.stor_id = sd.stor_id
                   AND sd.title_id = ti.title_id
                   AND st.state != 'CA');

--9
SELECT DISTINCT ti.title_id, ti.title
FROM titles ti,
     salesdetail sd,
     sales sa
WHERE ti.title_id = sd.title_id
  AND sd.ord_num = sa.ord_num
  AND sd.stor_id = sa.stor_id
  AND sa.date >= ALL (SELECT sa2.date
                      FROM sales sa2);
--ou AND sa.date = (SELECT MAX(sa2.date) FROM sales sa2);

--11
SELECT DISTINCT a.city
FROM authors a
WHERE a.state = 'CA'
  AND a.city NOT IN (SELECT st.city
                     FROM stores st);

--12
SELECT p.pub_id, p.pub_name
FROM publishers p
WHERE (p.city, p.state) IN (SELECT a.city, a.state
                 FROM authors a
                 GROUP BY a.city, a.state
                 HAVING COUNT(a.au_id) >= ALL (SELECT COUNT(a2.au_id)
                                               FROM authors a2
                                               GROUP BY a2.city, a2.state));
--13
SELECT DISTINCT t.title_id, t.title
FROM titles t, titleauthor ta
WHERE t.title_id = ta.title_id
AND ta.au_id NOT IN (SELECT a.au_id
                     FROM authors a
                     WHERE a.state != 'CA');

--15
SELECT t.title_id, t.title
FROM titles t, titleauthor ta
WHERE t.title_id = ta.title_id
GROUP BY t.title_id, t.title
HAVING COUNT(ta.au_id) = 1;

--16
SELECT t.title_id, t.title
FROM titles t, titleauthor ta
WHERE t.title_id = ta.title_id
AND ta.au_id IN (SELECT a.au_id
                     FROM authors a
                     WHERE a.state = 'CA')
AND 1 = (SELECT COUNT(ta1.au_id)
         FROM titleauthor ta1
         WHERE ta1.title_id = t.title_id);

