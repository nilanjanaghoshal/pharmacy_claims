-- Assigning PK to tables
use pharmacy_claims;
alter table pharmacy_claims.dim_brand_generic
add primary key (drug_brand_generic_code);

alter table pharmacy_claims.dim_drug_form_code
add column drug_code_desc_id int auto_increment primary key;

alter table pharmacy_claims.dim_drug_info
add primary key(drug_ndc);

alter table pharmacy_claims.dim_member
add primary key (member_id);

alter table pharmacy_claims.fact_drug
add id int not null auto_increment primary key;

-- Assigning FK to tables

alter table fact_drug
add foreign key fact_drug_member_id_fk(member_id)
references dim_member(member_id)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_drug_ndc_fk (drug_ndc)
references dim_drug_info(drug_ndc)
on delete set null
on update set null;

alter table fact_drug
add foreign key fact_drug_brand_generic_fk (drug_brand_generic_code)
references dim_brand_generic(drug_brand_generic_code)
on delete set null
on update set null;

alter table fact_drug
add foreign key dim_drug_code_drug_code_desc_id_fk(drug_code_desc_id)	
references dim_drug_form_code(drug_code_desc_id)
on delete set null
on update set null;


-- Analytics and Reporting
-- Question 1:

select d.drug_name, count(f.member_id) as number_prescriptions
from pharmacy_claims.dim_drug_info d 
inner join pharmacy_claims.fact_drug f
on d.drug_ndc = f.drug_ndc
group by drug_name;

-- Question 2

select case 
when d.member_age > 65 then '65+'
when d.member_age <65 then '<65'
end as age_group,
count(distinct d.member_id) as number_members,
sum(f.copay) as sum_copay,
sum(f.insurancepaid) as sum_insurancepaid,
count( f.member_id) as number_prescriptions
from dim_member d
inner join fact_drug f
on d.member_id = f.member_id
group by age_group;

-- Question 3

create table fill_fact as
select d.member_id, d.member_first_name, d.member_last_name, dr.drug_name,
str_to_date(f.fill_date, '%m/%d/%Y') as fill_date_fixed, f.insurancepaid 
from dim_member d
inner join fact_drug f
on d.member_id = f.member_id
inner join dim_drug_info dr
on dr.drug_ndc = f.drug_ndc;

select * 
from fill_fact;

create table insurancepaid_info as 
select member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurancepaid,
row_number() over (partition by member_id order by member_id, fill_date_fixed desc) as fill_times
from fill_fact;

select *
from insurancepaid_info;

select *
from insurancepaid_info
where fill_times = 1;


