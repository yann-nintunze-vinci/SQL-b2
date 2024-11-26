--2.g.ii
--2
SELECT st.stor_id, st.stor_name, st.stor_address, SUM(sd.qty * t.price) AS chiffre_affaire
FROM stores st
         LEFT OUTER JOIN salesdetail sd ON st.stor_id = sd.stor_id
         LEFT OUTER JOIN titles t ON sd.title_id = t.title_id
GROUP BY st.stor_id, st.stor_name, st.stor_address
ORDER BY chiffre_affaire DESC;

--4
SELECT t.type, t.title, a.au_id, a.au_lname, t.price
FROM titles t
         LEFT OUTER JOIN titleauthor ta ON t.title_id = ta.title_id
         LEFT OUTER JOIN authors a ON ta.au_id = a.au_id
WHERE t.price > 20
ORDER BY t.type, t.title_id;

--6
SELECT a.au_fname, a.au_lname, COUNT(t.title_id) AS nbre_livres
FROM authors a
         LEFT OUTER JOIN titleauthor ta ON a.au_id = ta.au_id
         LEFT OUTER JOIN titles t ON ta.title_id = t.title_id AND t.price > 20
GROUP BY a.au_fname, a.au_lname
ORDER BY nbre_livres, a.au_fname, a.au_lname;

--3
SELECT t.type, t.title, p.pub_name, t.price
FROM titles t,
     publishers p
WHERE t.pub_id = p.pub_id
  AND t.price > 20;

--2.h.ii
--1
SELECT a.au_fname, a.address, a.city, a.state, a.country, t.title_id, COALESCE(t.title, 'Aucun livre') AS title
FROM authors a
         LEFT OUTER JOIN titleauthor ta ON a.au_id = ta.au_id
         LEFT OUTER JOIN titles t ON ta.title_id = t.title_id
ORDER BY 6, 1;

--Donnez la liste complète des couples auteur-livre avec, pour chaque couple, le nom et le
--prénom de l'auteur, son adresse complète, ainsi que l'identifiant et le titre du livre. Les auteurs qui
--n'ont rien écrit doivent aussi figurer dans le résultat (avec "aucun livre" comme titre de livre). A
--l'affichage, les tuples relatifs au même livre doivent se suivre.