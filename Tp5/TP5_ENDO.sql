


1-Quels sont les chiffres d’affaires mensuels par Wilaya, pour chaque Producteur (Mois, 
NomWilaya, NomProducteur).

SELECT ph.CodeWilaya, ph.NomWilaya, Dt.mois , SUM(v.ca) as CAM, Pr.codeprod
FROM vente v , dpharmacie ph, DTepms DT, dproducteur pr
WHERE ph.codeph=v.codeph
and v.CodeTemps=DT.CodeTemps
and v.codeprod=pr.codeprod
GROUP BY ph.CodeWilaya, ph.NomWilaya, DT.mois,pr.codeprod

--2- Introduire les sous totaux (sur la requête 1) avec la clause rollup by
SELECT ph.CodeWilaya, ph.NomWilaya, DT.anneE, SUM(v.ca) as cam, pr.codeprod 
FROM vente v , Dpharmacie ph, DTepms DT, dproducteur pr 
WHERE ph.codeph=v.codeph 
and v.Codetemps=DT.CodeTemps
and v.codeprod=pr.codeprod
GROUP BY rollup (ph.CodeWilaya, ph.NomWilaya, DT.annee, pr.Codeprod)
ORDER BY ph.CodeWilaya, ph.NomWilaya, dt.annee, pr.codeprod;

--3- Introduire les sous totaux (sur la requête 1 avec la clause cube by)
SELECT ph.CodeWilaya, ph.NomWilaya, DT.anneE, SUM(v.ca) as cam, pr.codeprod 
FROM vente v , Dpharmacie ph, DTepms DT, dproducteur pr 
WHERE ph.codeph=v.codeph 
and v.Codetemps=DT.CodeTemps
and v.codeprod=pr.codeprod
GROUP BY cube (ph.CodeWilaya, ph.NomWilaya, DT.annee, pr.Codeprod)
ORDER BY ph.CodeWilaya, ph.NomWilaya, dt.annee, pr.codeprod; 

--4- Introduire la fonction groupping pour chaque dimension sur la requête 2
SELECT DA.CodeWilaya, DA.NomWilaya, DT.ANNÉE, SUM(FO.MontantV) as MontantV, DTC.CodeType,
grouping (DA.NomWilaya) as Region, grouping (DT.ANNÉE) as annee, grouping (DTC.CodeType) as Code
FROM FOperation FO, DAgence DA, DTemps DT, DTypeCompte DTC
WHERE DA.NumAgence=FO.NumAgence
and FO.CodeTemps=DT.CodeTemps
and FO.CodeTypeCompte=DTC.CodeType
GROUP BY rollup (DA.CodeWilaya, DA.NomWilaya, DT.ANNÉE, DTC.CodeType)
ORDER BY DA.CodeWilaya, DA.NomWilaya, DT.ANNÉE, DTC.CodeType;

--5- Remplacer la fonction groupping par la fonction grouping_id
select codeprod ,sum(ca) as caf Grouping_ID (codeprod)as prod from vente,dtepms where vente.CodeTemps=dtemps.CodeTemps group by rollup codeprod;
SELECT t.mois, h.NomWilaya, p.nomsprod, SUM(v.CA) AS CA,
GROUPING_ID(t.mois,h.NomWilaya , p.nomsprod) as GROUP_ID
FROM DProducteur p, DTePMS t, vente v, Dpharmacie h
WHERE v.CodeTemps = t.CodeTemps
AND p.codeprod = v.Codeprod
and v.codeph=h.codeph
GROUP BY ROLLUP(t.mois,h.NomWilaya , p.nomsprod)

5.Donner le classement dense et non dense des Types de médicaments dans chaque  année selon le nombre de boîtes. 
SELECT d.annee, m.type_medicament, SUM(v.nbboite) AS nboite,
RANK() OVER (PARTITION BY d.annee ORDER BY SUM(v.nbboite) DESC) AS Dense_ranking,
DENSE_RANK() OVER (PARTITION BY d.annee ORDER BY SUM(v.nbboite) DESC) AS non_dense_ranking
FROM vente v, DMedicament m,dtepms d
WHERE v.codemedic=m.codemedic AND v.CodeTemps=d.CodeTemps GROUP BY(d.annee, m.type_medicament);


6 Donner la répartition cumulative du nombre de boites, par Wilaya dans chaque 
année.

SELECT p.CodeWilaya, t.annee, SUM(v.nbboite) AS nboite,
CUME_DIST() OVER (PARTITION BY t.annee ORDER BY SUM(nbboite) desc) AS CA_CUMUL
FROM vente v, Dpharmacie p, DTepms t
WHERE p.codeph=v.codeph AND v.codetemps=t.CodeTemps
GROUP BY(p.CodeWilaya, t.annee);


 7)Donner pour chaque wilaya son chiffre d’affaire global, et segmenter les wilayas en 4 segments à l’aide de la fonction ntile

SELECT t.mois, SUM(v.CA) AS CA,
NTILE(4) OVER(order by t.mois) AS NTILE
FROM vente v, DTepms t
WHERE v.CodeTemps=t.CodeTemps
GROUP BY(t.mois); 

8. Donner les moyennes mobiles de chiffres d’affaires sur 3 mois.

SELECT T.Mois,Sum(CA) as CA,
AVG(Sum(CA)) Over (Order By Mois Rows 2 Preceding) as Moy_Mobile_3_Mois
FROM Dtepms T, Vente V
WHERE V.CodeTemps=T.CodeTemps
GROUP BY T.Mois;



9. Donner pour chaque Wilaya son ratio de nombre boites vendues dans chaque année.

SELECT t.annee, p.CodeWilaya, SUM(CA) as CA,
SUM(SUM(CA)) over(partition by(t.annee)) as CA_annuel,
ratio_to_report(SUM(CA)) over(partition by(t.annee)) as ratio
FROM vente v,Dpharmacie p, DTepms t
WHERE p.codeph=v.codeph and v.CodeTemps=t.CodeTemps
group by (t.annee, p.CodeWilaya)
order by t.annee, p.CodeWilaya;



10. Pour chaque année quel est la wilaya dont le nombre de boites est maximal.


SELECT Annee, CodeWilaya,NomWilaya,NBboite
FROM(
SELECT Annee as Annee, CodeWilaya as CodeWilaya,NomWilaya as NomWilaya,SUM(NBboite) as NbBoite, 
MAX(SUM(NBboite)) OVER (Partition by annee) as Max_NBoite 
From Vente V 
Inner JOIN Dpharmacie Ph
   ON V.CodePh = Ph.CodePh
INNER JOIN Dtepms t 
   ON V.CodeTemps=T.CodeTemps
group by (T.Annee, Ph.CodeWilaya,Ph.NomWilaya))
where NbBoite = Max_NBoite;


