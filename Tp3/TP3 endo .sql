create User magazin  identified by endo 
default tablespace system quota unlimited on system;
grant all privileges to magazin ;
/*creation des table*/
1.--- table DPharmacie-----

create table dpharmacie(
codeph number(10),
nomph  varchar(50),
codeville number(10),
nomville varchar(50),
CodeWilaya number(10),
nomwilaya varchar(50),
constraint pk_dpharm primary key (codeph);


2.---- table Dmedicament  ---
create table dmedicament (
codemedic number(10),
nommedic varchar(50),
generique number(1),
codetpmed number(10),
type_medicament varchar(50),
constraint pk_dmedic primary key (codemedic));
3.---- table Dmedecin -----
DMédecin(CodeMédecin, NomMédecin, CodeSpécialité, NomSpécialité)



create table dmedecin(
codemed number(10),
nommed varchar(50),
codespec number(10),
nomspec varchar(50),
constraint pk_dmed primary key (codemed));


4--------Table Dproducteur :


create table dProducteur(
codeprod number(10),
nomsprod varchar(50),
constraint pk_dprod primary key (codeprod));
4.--- table Dtepms ---
create table Dtepms(
codetemps number(10),
jour varchar(10),
LibJour varchar(10),
mois varchar(10),
libmois varchar(10),
annee varchar(10),
constraint pk_Dtepms primary key (codetemps)
);
5./*---* table fait *-----*/
Vente (CodePharmacie , CodeMédicament, CodeMédecin, CodeProducteur, CodeTemps, CA,
CARemboursable, NBBoite)
create table vente(
codeph number(10),
codemedic number(10),
codemed number(10),
codeprod number(10),
codetemps number(10),
CA  number(10),
CARemboursable number(10),
NBBoite  number(10),
constraint pk_vente primary key (codeph,codemed,codemedic,codeprod, codetemps),
constraint fk_Dmedecin foreign key (codemed) references Dmedecin(codemed) ,
constraint fk_Dpharm foreign key (codeph) references dpharmacie(codeph) ,
constraint fk_Dmedicament foreign key (codemedic) references Dmedicament(codemedic),
constraint fk_prod foreign key (codeprod) references Dproducteur(codeprod),
constraint fk_Dtemps foreign key (codetemps) references Dtepms (codetemps) 
);
/*----* pl-sql*------*/

1.-- remplissage de la table Dpaharmaci ---

begin
for i in 
(select system.pharmacie.codeph,system.pharmacie.nomph ,system.ville.codeville,system.ville.nomville,
system.wilaya.codewilaya,system.wilaya.nomwilaya
from system.pharmacie ,system.ville ,system.wilaya  
where system.pharmacie.codeville=system.ville.codeville and system.ville.codeville =system.wilaya.codewilaya)
loop
insert into dpharmacie d values(i.codeph,i.nomph ,i.codeville,i.nomville,i.codewilaya, i.nomwilaya);
end loop;
commit;
end ;
/
2.--remplissage de la table Dproducteur  --- 


begin
for i in
(select *
from system.producteur )
loop
insert into Dproducteur values(i.codeprod,i.nomsprod);
end loop;
commit;
end;
/


3.--- remplissage de la table Dmedecin----
begin
for i in 
(select codemed,nommed,s.codespec,s.nomspec
from system.medecin m,system.specialite s
where m.codespec=s.codespec )
loop
insert into Dmedecin values(i.codemed,i.nommed,i.codespec,i.nomspec);
end loop ;
commit;
end ;
/
4.---remplissage de la table Dmedicament----


begin
for i in 
(select codemedic,nommedic,generique, m.codetpmed ,s.typemed 
from system.medicament m,system.type_medicament s
where m.codetpmed=s.codetpmed)
loop
insert into Dmedicament values(i.codemedic,i.nommedic,i.generique,i.codetpmed ,i.typemed);
end loop ;
commit;
end ;
/
-----Temps ---------
4.1--création de séquence----


create  sequence seq
minvalue 1
maxvalue 100000
start with 1
increment by 1;


-------temps 
BEGIN
FOR i in (SELECT DISTINCT TO_CHAR(system.ordonnace.dateord,'DD/MM/YYYY') as jour,TO_CHAR(system.ordonnace.dateord,'DAY') as libjour,TO_CHAR(system.ordonnace.dateord,'MM/YYYY') as mois,TO_CHAR(system.ordonnace.dateord,'MONTH') as libmois,TO_CHAR(system.ordonnace.dateord,'YEAR') as annee FROM system.ordonnace) LOOP
INSERT INTO Dtepms VALUES(seq.NEXTVAL,i.jour,i.libjour,i.mois,i.libmois,i.annee);
END LOOP;
COMMIT;
END;
/


5.-- remplissage de la table  vente ---


begin
for i in
(select  codeph , codemedic,codemed, codeprod, codetemps,sum(d.prixboite) as ca , sum(d.prixref)as CARemboursable , 
count(d.codeboite) as NBBoite
from system.boite_medicament d , Dtepms t , system.ordonnace o 
where 
o.codeord= d.codeord

and t.jour=to_char(o.dateord,'DD/MM/YYYY')


group by(codeph,codemedic,codemed,codeprod, codetemps))
loop
insert into vente values(i.codeph,i.codemedic,i.codemed,i.codeprod, i.codetemps,i.ca,i.CARemboursable , i.NBBoite);
end loop;
commit;
end;
/



