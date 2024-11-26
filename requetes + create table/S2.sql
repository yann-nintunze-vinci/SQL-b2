--2.d.ii
--1
SELECT AVG(t.price) AS prix_moyen
FROM titles t,
     publishers p
WHERE t.pub_id = p.pub_id
  AND p.pub_name = 'Algodata Infosystems';

--2
SELECT a.au_id, a.au_fname, a.au_lname, AVG(t.price) AS prix_moyen
FROM authors a,
     titleauthor ta,
     titles t
WHERE a.au_id = ta.au_id
  AND t.title_id = ta.title_id
GROUP BY a.au_id, a.au_fname, a.au_lname;

--3
SELECT t.title_id, t.price, COUNT(ta.au_id) AS nb_auteurs
FROM publishers p,
     titles t
         LEFT OUTER JOIN titleauthor ta ON t.title_id = ta.title_id
WHERE t.pub_id = p.pub_id
  AND p.pub_name = 'Algodata Infosystems'
GROUP BY t.title_id, t.price;

--4
SELECT t.title_id, t.title, t.price, COUNT(DISTINCT sd.stor_id) AS nb_magasins
FROM titles t
         LEFT OUTER JOIN salesdetail sd ON t.title_id = sd.title_id
GROUP BY t.title_id, t.title, t.price;

--5
SELECT t.title_id, t.title, t.type, t.pub_id, t.price, t.total_sales, t.pubdate
FROM titles t,
     salesdetail sd
WHERE sd.title_id = t.title_id
GROUP BY t.title_id, t.title, t.type, t.pub_id, t.price, t.total_sales, t.pubdate
HAVING COUNT(DISTINCT sd.stor_id) > 1;

--6
SELECT t.type, COUNT(t.title_id) AS nb_livres, AVG(t.price) AS prix_moyen
FROM titles t
WHERE t.type IS NOT NULL
GROUP BY t.type;

--7
SELECT t.title_id, COALESCE(t.total_sales, 0) AS total_sales, COALESCE(SUM(sd.qty), 0) AS nb_ventes
FROM titles t
         LEFT OUTER JOIN salesdetail sd ON t.title_id = sd.title_id
GROUP BY t.title_id, t.total_sales;

--8
SELECT t.title_id, COALESCE(t.total_sales, 0) AS total_sales, COALESCE(SUM(sd.qty), 0) AS nb_ventes
FROM titles t
         LEFT OUTER JOIN salesdetail sd ON t.title_id = sd.title_id
GROUP BY t.title_id, t.total_sales
HAVING COALESCE(SUM(sd.qty), 0) != COALESCE(t.total_sales, 0);

--9
SELECT t.title_id, t.title, t.type, t.price, t.total_sales, t.pubdate
FROM titles t,
     titleauthor ta
WHERE ta.title_id = t.title_id
GROUP BY t.title_id, t.title, t.type, t.price, t.total_sales, t.pubdate
HAVING COUNT(ta.au_id) >= 3;

--10
SELECT SUM(sd.qty) AS nb_total_ventes
FROM publishers p,
     titles t,
     salesdetail sd,
     stores st
WHERE p.pub_id = t.pub_id
  AND t.title_id = sd.title_id
  AND st.stor_id = sd.stor_id
  AND p.state = 'CA'
  AND st.state = 'CA'
  AND t.title_id IN (SELECT ta.title_id
                     FROM titleauthor ta,
                          authors a
                     WHERE ta.au_id = a.au_id
                       AND a.state = 'CA');