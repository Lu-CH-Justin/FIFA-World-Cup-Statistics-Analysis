alter table players
add latest_wc int;

update players
set latest_wc = cast(substring_index(list_of_wc, ',', -1) as unsigned);

alter table tournaments
add type char(10);

update tournaments
set type = case when year % 2 = 0 then 'Men' else 'Women' end;
