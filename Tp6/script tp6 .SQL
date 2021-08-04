


-*-*-*+*-*-*-*-*-*-*-*-***
set timing on;
set autotrace on explain;
set line 200;
alter system flush shared_pool;
alter system flush buffer_cache;
1.
select count(*) from dmedicament where type_medicament='antibiotique';

2.
create index b_arbe on Dmedicament (type_medicament);

3.
alter system flush shared_pool;
alter system flush buffer_cache;

select /*+index(Dmedicament b_arbe)*/ count(*) from dmedicament where type_medicament='antibiotique';

4.
drop index b_arbe;

create  bitmap  index bitmap_inex on Dmedicament(type_medicament);

5.
select /*+index(Dmedicament bitmap_inex)*/  count(*) from dmedicament where type_medicament='antibiotique';

6.

select  sum(CA) as chiffre_daffaire_global
from  vente v,Dmedicament dm 
where  v.codemedic=dm.codemedic
and generique=1;

7.
create bitmap index index_jointure on vente (Dmedicament.generique)
from vente,Dmedicament
where vente.codemedic=dmedicament.codemedic

8.
alter system flush shared_pool;
alter system flush buffer_cache;

select /*+index(Dmedicament index_jointure)*/ sum(CA) as chiffre_dafre_globale
from  vente v,Dmedicament dm 
where  v.codemedic=dm.codemedic
and generique=1;

9.
select  sum(nbboite) as nombre_de_boite 
from vente v , dmedecin  dm 
where  v.codemed= dm.codemed
and dm.nomspec='cardiologie';
10.
create bitmap index index_jointure2 on vente(Dz.codewilaya)
from Fhospitalisation,Dpatient
Fhospitalisation.codepat=Dpatient.codepat;

create bitmap index index_jointure2 on vente(Dmedecin.nomspec)
from vente, dmedecin
where vente.codemed=dmedecin.codemed;
//and dmedecin.nomspec='cardiologie';

11.
select  /*+index(Dpatient index_jointure2)*/sum(nbboite) as nombre_de_boite 
from vente v , dmedecin  dm 
where  v.codemed= dm.codemed
and dm.nomspec='cardiologie';




create table vente2(
codeph number(10),
codemedic number(10),
codemed number(10),
codeprod number(10),
codetemps number(10),
CA  number(10),
CARemboursable number(10),
NBBoite  number(10),
constraint pk_vente2 primary key (codeph,codemed,codemedic,codeprod, codetemps),
constraint fk_Dmedecin2 foreign key (codemed) references Dmedecin(codemed) ,
constraint fk_Dpharm2 foreign key (codeph) references dpharmacie(codeph) ,
constraint fk_Dmedicament2 foreign key (codemedic) references Dmedicament(codemedic),
constraint fk_prod2 foreign key (codeprod) references Dproducteur(codeprod),
constraint fk_Dtemps2 foreign key (codetemps) references Dtepms (codetemps) 
) 
partition by range (codeprod)(
partition p1 values less than(50),
partition p2 values less than(78),
partition p3 values less than(100),
partition p4 values less than (maxvalue)
);
 P1{1…50}, P2{}, P3{}, P4>100. 
13.


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
insert into vente2 values(i.codeph,i.codemedic,i.codemed,i.codeprod, i.codetemps,i.ca,i.CARemboursable , i.NBBoite);
end loop;
commit;
end;
/

14. Ecrire une requête R4 qui donne le nombre de boites global du producteur N°104 en 
utilisant la table Vente.
select  sum(nbboite) as nombre_de_boite_104
from vente v
where v.codeprod=104;

15.
select  sum(nbboite) as nombre_de_boite_104
from vente2 v
where v.codeprod=104;



