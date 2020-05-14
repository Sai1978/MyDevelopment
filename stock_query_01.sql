-- 指定两个日期，依据期间个股的涨幅计算各行业的平均涨幅。
select C.xifenxingye, round(AVG(C.z_zhangfu),2) from (
select A.daima,A.xianjia, B.xianjia-A.xianjia,(B.xianjia-A.xianjia)/A.xianjia as z_zhangfu,A.xifenxingye from 
(SELECT daima,xianjia,xifenxingye FROM stock01.T_STOCK_01 where jiaoyiriqi = '20200203') A,
(SELECT daima,xianjia FROM stock01.T_STOCK_01 where jiaoyiriqi = '20200207') B where A.daima = B.daima) C group by C.xifenxingye order by 2 desc;
-- 指定日期和涨幅 寻找当日抗跌的股票 
select * from T_STOCK_01 where jiaoyiriqi='20200123' and zhangfu > -1 and 3rizhangfu >0 and 20rizhangfu >0 
and (xifenxingye not like '%药%' and xifenxingye not like '%医%' and mingcheng not like '%ST%') and ABguzongshizhi < 501 and yingyelirunyi > 0 ;
-- 2019年初至今涨幅 统计
select A.xifenxingye, A.CNT1, B.CNT2 from (select xifenxingye,count(*) as CNT1 from T_STOCK_01 where jiaoyiriqi = '20191230' and nianchuzhijin >= 100 and shangshiriqi <= '20190101' 
group by xifenxingye ) A left join (select xifenxingye,count(*) as CNT2 from T_STOCK_01 where jiaoyiriqi = '20191230' group by xifenxingye) B on A.xifenxingye = B.xifenxingye order by A.CNT1 desc; 
-- 数据库数据类型
select jiaoyiriqi,count(*) from T_STOCK_01 group by jiaoyiriqi;
-- 按照细分行业分组排名
select * from (
SELECT @rownum:=@rownum+1 inde,IF(@pxydm=a.xifenxingye,@rank:=@rank+1,@rank:=1) AS rank,     
       @pxydm:=a.xifenxingye, a.*  FROM
(select * from T_STOCK_01 where jiaoyiriqi = '20200123' order by xifenxingye desc,zongjindong desc,yingyelirunyi desc,ABguzongshizhi desc) a, (SELECT @rownum :=0, @pxydm := NULL,@rank:=0) b) XX
where XX.rank <=2 -- 只取排名前2条;

-- 指定日期和涨幅 寻找当日抗跌的股票 
insert into W_STOCK_01(jiaoyiriqi,daima,mingcheng,xifenxingye,beizhu1) 
SELECT '20200226',daima,mingcheng,xifenxingye,'当日抗跌'
FROM (
select daima,mingcheng,xifenxingye from T_STOCK_01 where jiaoyiriqi='20200226' and zhangfu > -1 and 3rizhangfu >0 and 20rizhangfu >0 
and (xifenxingye not like '%银行%' and xifenxingye not like '%地产%' and mingcheng not like '%ST%') and ABguzongshizhi < 1000 and yingyelirunyi > 0 
union all
-- 指定日期和涨幅 寻找当日抗跌的股票 
select daima,mingcheng,xifenxingye from T_STOCK_01 where jiaoyiriqi='20200203' and zhangfu > -8 and 3rizhangfu >0 and 20rizhangfu >0 
and (xifenxingye not like '%药%' and xifenxingye not like '%医%' and mingcheng not like '%ST%') and ABguzongshizhi < 1000 and yingyelirunyi > 0 ) a
GROUP BY daima,mingcheng,xifenxingye HAVING COUNT(*) > 1;
-- 指定日期，成交量前一百个股的统计 -----------
select xifenxingye,round(sum(zongjindong),0),round(avg(zhangfu),2) as zhangfu,count(*) from (
SELECT @rownum:=@rownum+1 as inde,daima,mingcheng,xifenxingye,zhangfu,zongjindong from T_STOCK_01 a,(SELECT @rownum :=0) b 
where jiaoyiriqi = '20200219'  order by zongjindong desc) XX
where XX.inde <=100 group by XX.xifenxingye order by 2 desc;
-- 交易金额在10E以上的股票分类.
select T1.jiaoyiriqi,T1.xifenxingye,round(sum(T1.zongjindong)/100000000,1) as 总金额,round(avg(T1.zhangfu),2) as 涨幅,count(*)  from T_STOCK_01 T1 
where T1.zongjindong > 1000000000 group by T1.jiaoyiriqi ,xifenxingye order by 1 desc,3 desc;
-- 每个交易日的连板数量 --衡量风险偏好指数
select jiaoyiriqi,count(*) from T_STOCK_01 
where zhangfu > 9.8 and 3rizhangfu >18 group by jiaoyiriqi order by 1 ;

-- 每个交易日的涨停板数 --衡量风险偏好指数
select jiaoyiriqi,count(*) from T_STOCK_01 
where zhangfu > 9.9 group by jiaoyiriqi order by 1 ;
