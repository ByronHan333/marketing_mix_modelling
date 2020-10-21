use mmm;

/* ---------------------------------------------- Paid Search ---------------------------------------------- */
/* Part I: create 2015 search_extracted */
create table search_extracted
(
select * from mmm_adwordssearch_2015
);
/* Part II: delete intersection */
delete a
from search_extracted a 
inner join mmm_adwordssearch_2017 b on a.date_id = b.date_id;
/* Part III: insert new table */
insert into search_extracted
select * from mmm_adwordssearch_2017;
/* Part IV:  test rows */
select 'end', count(*) from search_extracted;
select '2015', count(*) from mmm_adwordssearch_2015;
select 'intersect', count(*) from mmm_adwordssearch_2015 
where date_id in (select distinct date_id from mmm_adwordssearch_2017);
select '2017', count(*) from mmm_adwordssearch_2017;
/* Part V:  create a transform table ‘search_transformed’ to have 
SearchImpressions & SearchClicks variables by week */
create table search_transformed
(
select date_id, sum(impressions) as search_imp, sum(clicks) as search_clk 
from search_extracted group by 1
);
/* Part VI: create a new transform table
‘search_campaign_transformed’ to have SearchClicks variables */
create table search_campaign_transformed
(
select date_id, 
sum(if(campaign_name like '%Always-On%', clicks, 0)) as SearchAlwaysOnClick, 
sum(if(campaign_name in ('Landing Page', 'Retargeting'), clicks, 0)) as SearchWebsiteClick, 
sum(if(campaign_name in ('New Product Launch', 'Branding Campaign'), clicks, 0)) as SearchBrandingClick
from search_extracted
group by 1
);
select * from search_transformed;

/* ---------------------------------------------- Facebook ---------------------------------------------- */
/* Part II: Create transform table ‘facebook_extracted’ */
create table facebook_extracted
(
select *
from mmm_facebook
);
/* Part III: Create transform table ‘facebook_transformed’ */
create table facebook_transformed
(
select period, 
sum(ap_total_imps) as FacebookImpressions,
sum(ap_total_clicks) as FacebookClicks,
coalesce(round(1.0*sum(ap_total_clicks)/nullif(sum(ap_total_imps),0),4),0) as FacebookCTR
from facebook_extracted
group by 1
);
/* Part IV: Create transform table ‘fb_campaign_transformed’ */
create table fb_campaign_transformed
(
select period, 
sum(if(`Campaign Objective` in ('Branding Campaign', 'New Product Launch'), ap_total_imps, 0)) as FBBrandingImpression,
sum(if(`Campaign Objective` in ('Holiday', 'July 4th'), ap_total_imps, 0)) as FBHolidayImpression,
sum(if(`Campaign Objective` not in ('Branding Campaign', 'Holiday','New Product Launch','July 4th'), ap_total_imps, 0)) as FBOtherImpression
from mmm_facebook
group by 1
);

/* ---------------------------------------------- Wechat ---------------------------------------------- */
/* Part II: Create transform table ‘‘wechat_extracted’’ */
create table wechat_extracted
(
select * from mmm_wechat
);
/* Part III: Create transform table ‘‘wechat_transformed’’ */
create table wechat_transformed
(
select period, 
sum(`Article Total Read`+`Account Total Read`+`Moments Total Read`) as WechatTotalRead,
sum(if(Campaign='New Product Launch', `Article Total Read`+`Account Total Read`+`Moments Total Read`,0)) as WechatNewLaunchRead
from wechat_extracted 
group by 1
);
/* Part IV: final wechat table */
create table wechat_final 
(
select period, sum(`Article Total Read`) as `Article Total Read` 
from wechat_extracted 
group by 1
);

/* ---------------------------------------------- Offline data ---------------------------------------------- */
CREATE TABLE mmm.mmm_offline_transformed
(
SELECT
`Date`
,ROUND(SUM(`TV GRP`/100*`TOTAL HH`)/SUM(`TOTAL HH`)*100,1) AS `National TV GRP`
,ROUND(SUM(`Magazine GRP`/100*`TOTAL HH`)/SUM(`TOTAL HH`)*100,1) AS `Magazine GRP`
FROM mmm_offline_tv_magazine a
LEFT JOIN mmm_dma_hh b
ON a.`DMA` = b.`DMA Name`
GROUP BY `Date`
);

/* ---------------------------------------------- DCMdisplay ---------------------------------------------- */
CREATE TABLE mmm.mmm_dcmdisplay_transformed
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpressions`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpressions`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpressions`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpressions`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpressions`
,SUM(CONVERT(REPLACE(`Clicks`,',',''), SIGNED INTEGER)) AS `DisplayClicks`
,SUM(CONVERT(REPLACE(`Video Started`,',',''), SIGNED INTEGER)) AS `DisplayVideoStarted`
,SUM(CONVERT(REPLACE(`Video Fully Played`,',',''), SIGNED INTEGER)) AS `DisplayVideoFullyPlayed`
FROM mmm.mmm_dcmdisplay_2015
GROUP BY `Date`
);

CREATE TEMPORARY TABLE mmm.dcm_temp
(
SELECT
`Date`
,SUM(CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER)) AS `DisplayImpressions`
,SUM(IF(`Campaign Name` LIKE '%Always-On%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayAlwaysOnImpressions`
,SUM(IF(`Campaign Name` LIKE '%Website%',CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayWebsiteImpressions`
,SUM(IF(`Campaign Name` IN ('Branding Campaign','New Product Launch'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayBrandingImpressions`
,SUM(IF(`Campaign Name` IN ('Holiday','July 4th'),CONVERT(REPLACE(`Served Impressions`,',',''), SIGNED INTEGER),0)) AS `DisplayHolidayImpressions`
,SUM(CONVERT(REPLACE(`Clicks`,',',''), SIGNED INTEGER)) AS `DisplayClicks`
,SUM(CONVERT(REPLACE(`Video Started`,',',''), SIGNED INTEGER)) AS `DisplayVideoStarted`
,SUM(CONVERT(REPLACE(`Video Fully Played`,',',''), SIGNED INTEGER)) AS `DisplayVideoFullyPlayed`
FROM mmm.mmm_dcmdisplay_2017
GROUP BY `Date`
);

DELETE a
FROM mmm.mmm_dcmdisplay_transformed a
INNER JOIN mmm.dcm_temp b
ON a.`Date` = b.`Date`
;

INSERT INTO mmm.mmm_dcmdisplay_transformed
SELECT * FROM mmm.dcm_temp
;

/* ---------------------------------------------- Competitor Spending ---------------------------------------------- */
create table comp_media_spend_agg
(
select week, round(sum(`Competitive Media Spend`),0) as `Comp Media Spend`
from mmm_comp_media_spend 
group by 1
);

/* ---------------------------------------------- Special Event ---------------------------------------------- */
create table july_4th
(
select `day`, `week`, `Month`, 1 as july_4th_event
from mmm_date_metadata
where day(`day`)=4 and month(`day`)=7
);

create table black_friday
(
select `day`, `week`, 1 as black_friday_event from 
	(
    select `day`, `week`, row_number() over (partition by month(`day`), year(`day`) order by `day` asc) as row_num 
	from mmm_date_metadata
	where month(`day`)=11 and dayofweek(`day`)=6
    ) x
    where row_num=4
);

/* ---------------------------------------------- CCI ---------------------------------------------- */
create table cci
(
select CAST(STR_TO_DATE(period, '%m/%d/%Y') AS DATETIME) as period, cci from mmm_cci
);

/* ---------------------------------------------- Weekly Sales ---------------------------------------------- */
create table mmm.mmm_weekly_sales (
select week, round(sum(sales),2) as sales
from mmm.mmm_sales_raw a left join mmm.mmm_date_metadata b on a.`order date` = b.day
group by 1 order by 1 asc
);

/* ---------------------------------------------- Sales Event ---------------------------------------------- */
create table mmm.mmm_event_transform (
select max(if(b.day is not null, 1, 0)) as event, week
from mmm.mmm_date_metadata a left join mmm.mmm_event b on a.day = b.day
group by 2
order by 2 asc
);

/* ---------------------------------------------- Create Final View ---------------------------------------------- */
CREATE VIEW myview AS
select a.`Week` as `period`,
a.`Month` as `Month`,
cci as `CCI`, 
cast(`National TV GRP` as unsigned integer) as `National TV GRPs`,
cast(`Magazine GRP` as unsigned integer) as `Magazine GRPs`,
search_clk as`Paid Search`,
DisplayImpressions as `Display`,
FacebookImpressions as `Facebook Impression`,
`Article Total Read` as `Wechat`,
`event` as `Sales Event`,
coalesce(black_friday_event,0) as `Black Friday`,
coalesce(july_4th_event,0) as `July 4th`,
`Comp Media Spend` as `Comp Media Spend`,
cast(round(sales,0) as unsigned integer) as `Sales`,
DisplayAlwaysOnImpressions as `DisplayAlwaysOnImpression`,
DisplayBrandingImpressions as `DisplayBrandingImpression`,
DisplayWebsiteImpressions as `DisplayWebsiteImpression`, 
DisplayHolidayImpressions as `DisplayHolidayImpression`,
SearchBrandingClick as `SearchBrandingClick`,
SearchAlwaysOnClick as `SearchAlwaysOnClick`,
SearchWebsiteClick as `SearchWebsiteClick`,
FBBrandingImpression as `FacebookBrandingImpression`,
FBHolidayImpression as `FacebookHolidayImpression`,
FBOtherImpression as `FacebookOtherImpression`
from (SELECT DISTINCT `Week`,`Month` FROM mmm_date_metadata) a
left join search_transformed s on a.`Week`=s.date_id
left join fb_campaign_transformed b on a.`Week`=b.period
left join wechat_final c on a.`Week`=c.period
left join mmm_weekly_sales d on a.`Week`=d.`week`
left join mmm_dcmdisplay_transformed e on a.`Week`=e.`Date` 
left join search_campaign_transformed f on a.`Week`=f.date_id
left join mmm_offline_transformed g on a.`Week`=g.`Date`
left join comp_media_spend_agg h on a.`Week`=h.`week`
left join mmm_event_transform i on a.`Week`=i.`Week`
left join july_4th j on a.`Week`=j.`Week`
left join black_friday k on a.`Week`=k.`Week`
left join cci l on a.`Week`=l.period
left join facebook_transformed m on a.`Week`=m.period
;

select * from myview;