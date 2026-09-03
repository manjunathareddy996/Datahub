{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) UNPIVOT for SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE from 'pd_prop_sp_pv'.
-- 6 row(s), ONE PER INSTANCE of PANELROLECODE. Each source column is the SAME
-- attribute for a DIFFERENT panelrolecode; one column per source column would be the
-- wrong grain.

    select
        bagic_employee_code as parent_bk,
        'DFADVOCATE' as panelrolecode,
        acd_qualificationdfadvocate as academicqualification,
        bar_association_namedfadvocate as barassociationname,
        enrolment_nodfadvocate as barenrolmentnumber,
        covered_court_locdfadvocate as coveredcourtloc,
        lawyer_typedfadvocate as lawyertype,
        mrg_anniversarydfadvocate as marriageanniversarydate,
        mou_statusdfadvocate as moustatus,
        no_of_briefsdfadvocate as noofbriefs,
        no_of_companiesdfadvocate as noofcompanies,
        no_of_consumerdfadvocate as noofconsumer,
        no_of_juniorsdfadvocate as noofjunior,
        no_of_mactdfadvocate as noofmact,
        no_of_wcdfadvocate as noofwc,
        bagic_office_addressdfadvocate as servicinginsurerofficeaddress,
        yr_experiencedfadvocate as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationdfadvocate)), '') is not null or nullif(trim(to_varchar(bagic_office_addressdfadvocate)), '') is not null or nullif(trim(to_varchar(bar_association_namedfadvocate)), '') is not null or nullif(trim(to_varchar(covered_court_locdfadvocate)), '') is not null or nullif(trim(to_varchar(enrolment_nodfadvocate)), '') is not null or nullif(trim(to_varchar(lawyer_typedfadvocate)), '') is not null or nullif(trim(to_varchar(mou_statusdfadvocate)), '') is not null or nullif(trim(to_varchar(mrg_anniversarydfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_briefsdfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_companiesdfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_consumerdfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_juniorsdfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_mactdfadvocate)), '') is not null or nullif(trim(to_varchar(no_of_wcdfadvocate)), '') is not null or nullif(trim(to_varchar(yr_experiencedfadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'HCADVOCATE' as panelrolecode,
        acd_qualificationhcadvocate as academicqualification,
        bar_association_namehcadvocate as barassociationname,
        enrolment_nohcadvocate as barenrolmentnumber,
        covered_court_lochcadvocate as coveredcourtloc,
        lawyer_typehcadvocate as lawyertype,
        mrg_anniversaryhcadvocate as marriageanniversarydate,
        mou_statushcadvocate as moustatus,
        no_of_briefshcadvocate as noofbriefs,
        no_of_companieshcadvocate as noofcompanies,
        no_of_consumerhcadvocate as noofconsumer,
        no_of_juniorshcadvocate as noofjunior,
        no_of_macthcadvocate as noofmact,
        no_of_wchcadvocate as noofwc,
        bagic_office_addresshcadvocate as servicinginsurerofficeaddress,
        yr_experiencehcadvocate as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationhcadvocate)), '') is not null or nullif(trim(to_varchar(bagic_office_addresshcadvocate)), '') is not null or nullif(trim(to_varchar(bar_association_namehcadvocate)), '') is not null or nullif(trim(to_varchar(covered_court_lochcadvocate)), '') is not null or nullif(trim(to_varchar(enrolment_nohcadvocate)), '') is not null or nullif(trim(to_varchar(lawyer_typehcadvocate)), '') is not null or nullif(trim(to_varchar(mou_statushcadvocate)), '') is not null or nullif(trim(to_varchar(mrg_anniversaryhcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_briefshcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_companieshcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_consumerhcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_juniorshcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_macthcadvocate)), '') is not null or nullif(trim(to_varchar(no_of_wchcadvocate)), '') is not null or nullif(trim(to_varchar(yr_experiencehcadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'LAWYER' as panelrolecode,
        acd_qualificationlawyer as academicqualification,
        bar_association_namelawyer as barassociationname,
        enrolment_nolawyer as barenrolmentnumber,
        covered_court_loclawyer as coveredcourtloc,
        lawyer_typelawyer as lawyertype,
        mrg_anniversarylawyer as marriageanniversarydate,
        mou_statuslawyer as moustatus,
        no_of_briefslawyer as noofbriefs,
        no_of_companieslawyer as noofcompanies,
        no_of_consumerlawyer as noofconsumer,
        no_of_juniorslawyer as noofjunior,
        no_of_mactlawyer as noofmact,
        no_of_wclawyer as noofwc,
        bagic_office_addresslawyer as servicinginsurerofficeaddress,
        yr_experiencelawyer as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationlawyer)), '') is not null or nullif(trim(to_varchar(bagic_office_addresslawyer)), '') is not null or nullif(trim(to_varchar(bar_association_namelawyer)), '') is not null or nullif(trim(to_varchar(covered_court_loclawyer)), '') is not null or nullif(trim(to_varchar(enrolment_nolawyer)), '') is not null or nullif(trim(to_varchar(lawyer_typelawyer)), '') is not null or nullif(trim(to_varchar(mou_statuslawyer)), '') is not null or nullif(trim(to_varchar(mrg_anniversarylawyer)), '') is not null or nullif(trim(to_varchar(no_of_briefslawyer)), '') is not null or nullif(trim(to_varchar(no_of_companieslawyer)), '') is not null or nullif(trim(to_varchar(no_of_consumerlawyer)), '') is not null or nullif(trim(to_varchar(no_of_juniorslawyer)), '') is not null or nullif(trim(to_varchar(no_of_mactlawyer)), '') is not null or nullif(trim(to_varchar(no_of_wclawyer)), '') is not null or nullif(trim(to_varchar(yr_experiencelawyer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'RETAINER' as panelrolecode,
        acd_qualificationretainer as academicqualification,
        bar_association_nameretainer as barassociationname,
        enrolment_noretainer as barenrolmentnumber,
        covered_court_locretainer as coveredcourtloc,
        lawyer_typeretainer as lawyertype,
        mrg_anniversaryretainer as marriageanniversarydate,
        mou_statusretainer as moustatus,
        no_of_briefsretainer as noofbriefs,
        no_of_companiesretainer as noofcompanies,
        no_of_consumerretainer as noofconsumer,
        no_of_juniorsretainer as noofjunior,
        no_of_mactretainer as noofmact,
        no_of_wcretainer as noofwc,
        bagic_office_addressretainer as servicinginsurerofficeaddress,
        yr_experienceretainer as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationretainer)), '') is not null or nullif(trim(to_varchar(bagic_office_addressretainer)), '') is not null or nullif(trim(to_varchar(bar_association_nameretainer)), '') is not null or nullif(trim(to_varchar(covered_court_locretainer)), '') is not null or nullif(trim(to_varchar(enrolment_noretainer)), '') is not null or nullif(trim(to_varchar(lawyer_typeretainer)), '') is not null or nullif(trim(to_varchar(mou_statusretainer)), '') is not null or nullif(trim(to_varchar(mrg_anniversaryretainer)), '') is not null or nullif(trim(to_varchar(no_of_briefsretainer)), '') is not null or nullif(trim(to_varchar(no_of_companiesretainer)), '') is not null or nullif(trim(to_varchar(no_of_consumerretainer)), '') is not null or nullif(trim(to_varchar(no_of_juniorsretainer)), '') is not null or nullif(trim(to_varchar(no_of_mactretainer)), '') is not null or nullif(trim(to_varchar(no_of_wcretainer)), '') is not null or nullif(trim(to_varchar(yr_experienceretainer)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'STADVOCATE' as panelrolecode,
        acd_qualificationstadvocate as academicqualification,
        bar_association_namestadvocate as barassociationname,
        enrolment_nostadvocate as barenrolmentnumber,
        covered_court_locstadvocate as coveredcourtloc,
        lawyer_typestadvocate as lawyertype,
        mrg_anniversarystadvocate as marriageanniversarydate,
        mou_statusstadvocate as moustatus,
        no_of_briefsstadvocate as noofbriefs,
        no_of_companiesstadvocate as noofcompanies,
        no_of_consumerstadvocate as noofconsumer,
        no_of_juniorsstadvocate as noofjunior,
        no_of_mactstadvocate as noofmact,
        no_of_wcstadvocate as noofwc,
        bagic_office_addressstadvocate as servicinginsurerofficeaddress,
        yr_experiencestadvocate as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationstadvocate)), '') is not null or nullif(trim(to_varchar(bagic_office_addressstadvocate)), '') is not null or nullif(trim(to_varchar(bar_association_namestadvocate)), '') is not null or nullif(trim(to_varchar(covered_court_locstadvocate)), '') is not null or nullif(trim(to_varchar(enrolment_nostadvocate)), '') is not null or nullif(trim(to_varchar(lawyer_typestadvocate)), '') is not null or nullif(trim(to_varchar(mou_statusstadvocate)), '') is not null or nullif(trim(to_varchar(mrg_anniversarystadvocate)), '') is not null or nullif(trim(to_varchar(no_of_briefsstadvocate)), '') is not null or nullif(trim(to_varchar(no_of_companiesstadvocate)), '') is not null or nullif(trim(to_varchar(no_of_consumerstadvocate)), '') is not null or nullif(trim(to_varchar(no_of_juniorsstadvocate)), '') is not null or nullif(trim(to_varchar(no_of_mactstadvocate)), '') is not null or nullif(trim(to_varchar(no_of_wcstadvocate)), '') is not null or nullif(trim(to_varchar(yr_experiencestadvocate)), '') is not null
    union all
    select
        bagic_employee_code as parent_bk,
        'TRADVOCATE' as panelrolecode,
        acd_qualificationtradvocate as academicqualification,
        bar_association_nametradvocate as barassociationname,
        enrolment_notradvocate as barenrolmentnumber,
        covered_court_loctradvocate as coveredcourtloc,
        lawyer_typetradvocate as lawyertype,
        mrg_anniversarytradvocate as marriageanniversarydate,
        mou_statustradvocate as moustatus,
        no_of_briefstradvocate as noofbriefs,
        no_of_companiestradvocate as noofcompanies,
        no_of_consumertradvocate as noofconsumer,
        no_of_juniorstradvocate as noofjunior,
        no_of_macttradvocate as noofmact,
        no_of_wctradvocate as noofwc,
        bagic_office_addresstradvocate as servicinginsurerofficeaddress,
        yr_experiencetradvocate as yearsofpractice,
        'pd_prop_sp_pv' as record_source
    from {{ ref('stg_maximus__pd_prop_sp_pv') }}
    where nullif(trim(to_varchar(acd_qualificationtradvocate)), '') is not null or nullif(trim(to_varchar(bagic_office_addresstradvocate)), '') is not null or nullif(trim(to_varchar(bar_association_nametradvocate)), '') is not null or nullif(trim(to_varchar(covered_court_loctradvocate)), '') is not null or nullif(trim(to_varchar(enrolment_notradvocate)), '') is not null or nullif(trim(to_varchar(lawyer_typetradvocate)), '') is not null or nullif(trim(to_varchar(mou_statustradvocate)), '') is not null or nullif(trim(to_varchar(mrg_anniversarytradvocate)), '') is not null or nullif(trim(to_varchar(no_of_briefstradvocate)), '') is not null or nullif(trim(to_varchar(no_of_companiestradvocate)), '') is not null or nullif(trim(to_varchar(no_of_consumertradvocate)), '') is not null or nullif(trim(to_varchar(no_of_juniorstradvocate)), '') is not null or nullif(trim(to_varchar(no_of_macttradvocate)), '') is not null or nullif(trim(to_varchar(no_of_wctradvocate)), '') is not null or nullif(trim(to_varchar(yr_experiencetradvocate)), '') is not null
