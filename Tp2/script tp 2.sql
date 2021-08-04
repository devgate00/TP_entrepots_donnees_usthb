      // TP2

  // 1-Création d’une vue matérialisée VM1 :
  CREATE MATERIALIZED VIEW VM1
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
  AS SELECT codeord , dateord
     FROM ordonnace  
          WHERE dateord BETWEEN ‘01-07-2020’ AND ‘31-07-2020’;

  //Creation de journale de vues : 

CREATE MATERIALIZED VIEW LOG ON ordonnace;

  // 2-Création d’une vue matérialisée VM2 :
  CREATE MATERIALIZED VIEW  VM2
  BUILD IMMEDIATE
  REFRESH FAST ON DEMAND
  AS SELECT codeord , dateord
     FROM ordonnace  
          WHERE dateord BETWEEN ‘01-07-2020’ AND ‘31-07-2020’;

  //3-Testez les répercussions des mises à jour de la table ordonnance sur les 2 vues :
      //3.1- L’insertion :
       Insert into ordonnace values (956251,
                                      TO_DATE (TRUNC (DBMS_RANDOM.VALUE(TO_CHAR (DATE '2018-01- 01','J'), TO_CHAR (DATE '2021-12-31','J'))), ‘J’),
                                      floor (dbms_random.value (10, 17600.9)), 
                                      floor (dbms_random.value (10, 25314.9)), 
                                      floor (dbms_random.value (10, 150566.9))
                                      );


      // Raffraichissement des vues :
         Execute DBMS_MVIEW.REFRESH('VM1');
         Execute DBMS_MVIEW.REFRESH('VM2');

       //3.2- La suppression :
        Delete from ordonnace where codeord = 956251;

       // Raffraichissement des vues :
         Execute DBMS_MVIEW.REFRESH('VM1');
         Execute DBMS_MVIEW.REFRESH('VM2');
  
       //3.3- La modification :
         Update ordonnace set dateord= ’01-09-2020’ where codeord =6 ;

       // Raffraichissement des vues :
         Execute DBMS_MVIEW.REFRESH('VM1');
         Execute DBMS_MVIEW.REFRESH('VM2');

// D) Activer les options autotrace, et timing de oracle. (set autotrace on, set timing on)

       set autotrace on
       set timingo on 
  //E)  Ecrire une requête R1 pour obtenir la liste des Patients (CodePat, NomPat) traités par des médecins cardiologues. 
//Tout d’abord nous allons  modifier une ligne quelconque de la table spécialité pour avoir la valeur cardiologie
Update specialite  set nomspec= ’cardiologie’ where codespec =1 ;

//requête R1

SELECT p.codepat, p.nompat , s.nomspec from patient p , medecin m , ordonnace o , specialite s
where (p.codepat= o.codepat AND m.codemed= o.codemed AND m.codespec= 1);


// Créer une vue matérialisée VM3 en utilisant les options (IMMEDIATE, COMPLETE,
ON DEMAND, ENABLE QUERY REWRITE) contenant une jointure entre les tables
Patient, ordonnance, médecin et spécialité

CREATE MATERIALIZED VIEW VM3
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
as 
SELECT p.codepat, p.nompat , m.codemed,o.codeord from  patient p , specialite s,medecin m,ordonnace o
where p.codepat= o.codepat 
AND m.codemed=o.codemed
AND m.codespec= s.codespec ;

//Ecrire une requête R2 pour obtenir le nombre d’ordonnances par Année (Année,
NBOrd)
SELECT count( o.codeord) ,EXTRACT(YEAR from o.dateord) 
from ordonnace o 
Group by EXTRACT(YEAR from o.dateord) ;


//Créer une vue matérialisée VM4 (Année, NbOrd) en utilisant les options
(IMMEDIATE, COMPLETE, ON DEMAND, ENABLE QUERY REWRITE)

CREATE MATERIALIZED VIEW VM4
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
as SELECT count( o.codeord) ,EXTRACT(YEAR from o.dateord) 
from ordonnace o 
Group by EXTRACT(YEAR from o.dateord) ;

//On noublie pas de vider les buffer après chaque exécution des requêtes :
alter system flush shared_pool; 
alter system flush buffer_cache;
//I)  Augmenter le nombre d’instances de ordonnance à 1500000, puis à 2000000

 // Modifier instance 1500000 Remplir la table Ordonnance:

 DECLARE
 
 I number;
 D date;
 W number(10);
 S number(10);
 V number(10);
 begin for i in 956251.. 1500000 loop
 
 SELECT TO_DATE( TRUNC( DBMS_RANDOM.VALUE(TO_CHAR(DATE '2018-01-01','J') ,TO_CHAR(DATE '2021-12-31','J') ) ),'J' ) into d FROM DUAL;
 Select floor(dbms_random.value(10, 25314.9)) into w from dual;
Select floor(dbms_random.value(10, 17600.9)) into v from dual;
Select floor(dbms_random.value(10, 150566.9)) into s from dual;

 insert into ordonnace values(i,d,w,v,s);
 end loop;
 commit; 
 end;
 /


  // Modifier instance 2000000 Remplir la table Ordonnance:

 DECLARE
 
 I number;
 D date;
 W number(10);
 S number(10);
 V number(10);
 begin for i in 1500001.. 2000000 loop
 
 SELECT TO_DATE( TRUNC( DBMS_RANDOM.VALUE(TO_CHAR(DATE '2018-01-01','J') ,TO_CHAR(DATE '2021-12-31','J') ) ),'J' ) into d FROM DUAL;
 Select floor(dbms_random.value(10, 25314.9)) into w from dual;
Select floor(dbms_random.value(10, 17600.9)) into v from dual;
Select floor(dbms_random.value(10, 150566.9)) into s from dual;

 insert into ordonnace values(i,d,w,v,s);
 end loop;
 commit; 
 end;
 /

 //EXecuter VM4
 Select * FROM VM4;
 
