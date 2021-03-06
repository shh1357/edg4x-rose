-- Given a database containing both syntactic clusters and semantic similarity information, compute pairs of functions
-- that are both syntactically and semantically similar.  Tables are prefixed with "ipt" for "intellectual property theft".

drop table if exists ipt_combined_pairs;
drop table if exists ipt_semantic_pairs;
drop table if exists ipt_syntactic_pairs;
drop table if exists ipt_parameters;

-- Change these values to whatever you want
create table ipt_parameters as select
  0.7 as semantic_similarity,		-- min similarity for two functions to be considered semantic clones
  0.1 as syntactic_overlap;             -- min vector overlap for two functions to be considered syntactic clones

-- Pairs of syntactic clones (func1_id < func2_id)
create table ipt_syntactic_pairs as
  select distinct function_id_1 as func1_id, function_id_2 as func2_id
  from cluster_pairs
  where ratio_1 >= (select syntactic_overlap from ipt_parameters) and
        ratio_2 >= (select syntactic_overlap from ipt_parameters);

-- Pairs of semantic clones (func1_id < func2_id)
create table ipt_semantic_pairs as
  select func1_id, func2_id
  from semantic_funcsim
  where similarity >= (select semantic_similarity from ipt_parameters);

-- Pairs of functions that are both syntactic and semantic clones
create table ipt_combined_pairs as
  select * from ipt_syntactic_pairs
  intersect
  select * from ipt_semantic_pairs;


-- False negative/positive rates (cut-n-pasted from failure-rate.sql and changed the name of a table

begin transaction;

drop table if exists fr_results;
drop table if exists fr_false_positives;
drop table if exists fr_false_negatives;
drop table if exists fr_clone_pairs;
drop table if exists fr_negative_pairs;
drop table if exists fr_positive_pairs;
drop table if exists fr_function_pairs;
drop table if exists fr_cluster_pairs;
drop table if exists fr_functions;
drop table if exists fr_funcnames;
drop table if exists fr_specimens;

-- Files that are binary specimens; i.e., not shared libraries, etc.
create table fr_specimens as
    select distinct specimen_id as id
    from semantic_functions;

-- Function names that are present exactly once in each specimen
-- And which contain a certain number of instructions                                           !!FIXME: should be a parameter
-- And which come from the specimen, not from a dynamic library
create table fr_funcnames as
    select func1.name as name
        from fr_specimens as file
        join semantic_functions as func1 on func1.file_id = file.id
        left join semantic_functions as func2
            on func1.id<>func2.id and func1.name <> '' and func1.name=func2.name and func1.file_id=func2.file_id
        where func2.id is null and func1.ninsns >= 2                                            -- !!FIXME
        group by func1.name
        having count(*) = (select count(*) from fr_specimens);


-- Functions that have a name and which appear once per specimen by that name.
create table fr_functions as
    select distinct func.*
        from fr_funcnames as named
        join semantic_functions as func on named.name = func.name;

-- Pairs of functions that we want to consider
create table fr_cluster_pairs as
    select pair.*
        from ipt_combined_pairs as pair
        join fr_functions as func1 on pair.func1_id = func1.id
	join fr_functions as func2 on pair.func2_id = func2.id;

-- Select all pairs of functions from two different specimens
create table fr_function_pairs as
    select distinct f1.id as func1_id, f2.id as func2_id
        from fr_functions as f1
        join fr_functions as f2 on f1.id < f2.id and f1.specimen_id <> f2.specimen_id;

-- Pairs of functions that should have been detected as being similar.  We're assuming that any pair of binary functions that
-- have the same name are in fact the same function at the source level and should therefore be similar.
create table fr_positive_pairs as
    select pair.*
        from fr_function_pairs as pair
        join fr_functions as f1 on pair.func1_id = f1.id
        join fr_functions as f2 on pair.func2_id = f2.id
        where f1.name = f2.name;

-- Pairs of functions that should not have been detected as being similar.  We're assuming that if the two functions have
-- different names then they are different functions in the source code, and that no two functions in source code are similar.
-- That second assumption almost certainly doesn't hold water!
create table fr_negative_pairs as
    select pair.*
        from fr_function_pairs as pair
        join fr_functions as f1 on pair.func1_id = f1.id
        join fr_functions as f2 on pair.func2_id = f2.id
        where f1.name <> f2.name;

-- Pairs of functions that were _detected_ as being similar.
create table fr_clone_pairs as
    select distinct func1_id, func2_id
        from fr_cluster_pairs;

-- Table of false negative pairs.  These are pairs of functions that were not determined to be similar but which are present
-- in the fr_positives_pairs table.
create table fr_false_negatives as
    select * from fr_positive_pairs except select func1_id, func2_id from fr_clone_pairs;

-- Table of false positive pairs.  These are pairs of functions that were determined to be similar but which are present
-- in the fr_negative_pairs table.
create table fr_false_positives as
    select * from fr_negative_pairs intersect select func1_id, func2_id from fr_clone_pairs;

-- False negative rate is the ratio of false negatives to expected positives
-- False positive rate is the ratio of false positives to expected negatives
create table fr_results as
    select
        (select count(*) from fr_positive_pairs) as "Expected Positives",
        (select count(*) from fr_negative_pairs) as "Expected Negatives",
        (select count(*) from fr_false_negatives) as "False Negatives",
        (select count(*) from fr_false_positives) as "False Positives",
        ((select 100.0*count(*) from fr_false_negatives) / (select count(*) from fr_positive_pairs)) as "FN Percent",
        ((select 100.0*count(*) from fr_false_positives) / (select count(*) from fr_negative_pairs)) as "FP Percent";

-------------------------------------------------------------------------------------------------------------------------------
-- Some queries to show the results

select * from fr_results;

-- select 'The following table shows the false negative function pairs.
-- Both functions of the pair always have the same name.' as "Notice";
-- select
--         func1.name as name,
--         falseneg.func1_id, falseneg.func2_id
--     from fr_false_negatives as falseneg
--     join fr_functions as func1 on falseneg.func1_id = func1.id
--     join fr_functions as func2 on falseneg.func2_id = func2.id
--     order by func1.name;

rollback;
