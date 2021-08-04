1)*-*-*-*
select count(NBBoite) from DMedecin dm ,vente v
where dm.NomSpecialite='cardiolog' and dm.CodeMedecin=v.CodeMedecin ;
2)*-*-*--*
CREATE MATERIALIZED VIEW VMSpecialite
  BUILD IMMEDIATE REFRESH COMPLETE ON commit 
  ENABLE QUERY REWRITE 
 AS SELECT  CodeSpecialite,NomSpecialite,count(NBBoite) from DMedecin dm ,vente v
where  dm.CodeMedecin=v.CodeMedecin group by (dm.CodeSpecialite,dm.NomSpecialite);
3)*-*-*-*-* Reexecution R1


4)*--*-*-*-*
create materialized view VMCAMensuel
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
enable query rewrite
as select Mois , sum(ca)
FROM DTemps dt, vente v WHERE dt.CodeTemps=v.CodeTemps
GROUP BY (dt.Mois);

5)*-*-*-*-*
select Annee , sum(ca)
FROM DTemps dt, vente v WHERE dt.CodeTemps=v.CodeTemps
GROUP BY (dt.Annee);

6)--*-*-*-*
CREATE DIMENSION dim_DPharmacie
LEVEL CodePharmacie IS (DPharmacie.CodePharmacie)
LEVEL odeVille IS (DPharmacie.odeVille)
LEVEL CodeWilaya IS (DPharmacie.CodeWilaya)
HIERARCHY H_DPhar (CodePharmacie CHILD OF odeVille CHILD OF CodeWilaya)
ATTRIBUTE CodePharmacie DETERMINES (DPharmacie.NomPharmacie)
ATTRIBUTE odeVille DETERMINES (DPharmacie.NomVille)
ATTRIBUTE CodeWilaya DETERMINES (DPharmacie.NomWilaya);

CREATE DIMENSION dim_DMedicament
LEVEL CodeMedicament IS (DMedicament.CodeMedicament)
LEVEL CodeTypMedicament IS (DMedicament.CodeTypMedicame nt)
LEVEL Generique IS (DMedicament.Generique)
HIERARCHY H_DMed (CodeMedicament CHILD OF CodeTypMedicament)
HIERARCHY H1_DMed (CodeMedicament CHILD OF Generique)
ATTRIBUTE CodeMedicament DETERMINES (DMedicament.NomMedicament)
ATTRIBUTE CodeTypMedicament DETERMINES (DMedicament.TypeMedicament);

CREATE DIMENSION dim_DMedecin
LEVEL CodeMedecin IS (DMedecin.CodeMedecin)
LEVEL CodeSpecialite IS (DMedecin.CodeSpecialite)
HIERARCHY H_DMdc (CodeMedecin CHILD OF CodeSpecialite)
ATTRIBUTE CodeMedecin DETERMINES (DMedecin.NomMedecin)
ATTRIBUTE CodeSpecialite DETERMINES (DMedecin.NomSpecialite);

CREATE DIMENSION dim_DTemps
LEVEL CodeTemps IS (DTemps.CodeTemps)
LEVEL Jour IS (DTemps.Jour)
LEVEL Mois IS (DTemps.Mois)
LEVEL Annee IS (DTemps.Annee)
HIERARCHY dtmp_h1(CodeTemps CHILD OF Jour CHILD OF Mois CHILD OF Annee)
ATTRIBUTE Jour  DETERMINES (DTemps.LibJour)
ATTRIBUTE mois  DETERMINES (DTemps.libmois);

7)*-*-*-*-* rexecution de la requete ----*/
Alter session set query_rewrite_integrity=trusted;
8)*-*-*-*-*rexecution de la requete---*/

9)*-*-*-*-*
create materialized view VMCAVille
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
enable query rewrite
as select odeVille ,NomVille ,count (CA)
FROM DPharmacie dph, vente v WHERE dph.CodePharmacie=v.CodePharmacie
GROUP BY (odeVille,NomVille);

10)*-**-*-*-
select CodeWilaya ,NomWilaya  ,count (CA) as realise
FROM DPharmacie dph, vente v WHERE dph.CodePharmacie=v.CodePharmacie
GROUP BY (CodeWilaya ,NomWilaya);


/**11***/

/***12**/
drop dimension dim_DPharmacie;

alter system flush shared_pool;                                                 
alter system flush buffer_cache;