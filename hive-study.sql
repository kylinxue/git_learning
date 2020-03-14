
-- Recover Partition 修复分区
  -- 1. 通过HDFS put/cp命令往表目录下拷贝分区目录
  -- 2. Hive会检测如果HDFS目录下存在但表的metastore中不存在的partition元信息，更新到metastore中
MSCK REPAIR TABLE table_name;
-- 如果自动修复不成功，可以手动修复 
alter table table_name add if not exists partition(pt_d='20190505', pt_service='hota')

hadoop fs -du -h /dir/sub_dir -- 查看目录下每一个文件的大小


-- 对已存在的表新增字段，原有的分区不会改变，新分区才会发生变化
 -- step1：对表新增分区
alter table bicoredata.dwd_loc_country_ds add columns (
    mcc  VARCHAR(16)  COMMENT 'MCC'
);
 -- step2：对变更检测的分区【该分区必须存在，变更日期前4、5天即可】执行新增字段
alter table bicoredata.dwd_loc_country_ds partition (pt='20190410') add columns (
    mcc  VARCHAR(16)  COMMENT 'MCC'
)

-- 新增字段处理
 # 如果是新增分区字段 pt_service，可以将历史数据移动到others分区【hadoop fs mv + add partition】，重刷1个月之内的数据【重跑脚本】;
 # 如果是天分区拆分成小时分区，新增pt_h字段，将历史数据move到小时表的pt_h='24'的分区，变更日期之后正常从ods的小时表抽取即可;
 # 如果新增普通字段——oaid，直接重新执行脚本即可【一般不需要重刷】

-- 创建临时表的方案
 create table temp.xxx as select 的方式是将hivestaging临时文件写到当前库的location中
 insert table 的方式是将hivestaging临时文件写到目标表的location中
 结论：最好使用 insert table 的方式，避免移动hivestaging临时文件导致性能下降。
 
-- 1,0 [全周期依赖,不忽略错误]    是否全周期依赖，是否忽略错误
 
--# shell光标使用技巧
 # Ctr + a 移动光标到行首 
 # Ctr + e 移动光标到行尾
 # Ctr + w 剪切前一个单词(空格间隔的字符串单元) 
 # Ctr + u 剪切到行首 
 # Ctr + k 剪切到行尾 
 # Ctr + y 粘贴剪切
 
-- shell脚本
 $# 是传给脚本的参数个数
 $0 是脚本本身的名字
 $1 是传递给该shell脚本的第一个参数
 $2 是传递给该shell脚本的第二个参数
 $@ 是传给脚本的所有参数的列表
 $* 是以一个单字符串显示所有向脚本传递的参数，与位置变量不同，参数可超过9个
 $$ 是脚本运行的当前进程ID号
 $? 是显示上一条命令的退出状态，0表示没有错误，其他表示有错误


 -- 查询数据
select count(*)
from tmp_xwx705275_20190402_dws_xxx_dm_1;
 -- 删除临时表
drop table if exists tmp_xwx705275_20190402_dws_xxx_dm_1;

-- 备份待带变更表分区的数据
##变更验证方法:
##01 变更验证前，需要选取一个历史分区用于验证。尽量选一个星期左右的，然后查询反向依赖尽量保证所有的反向依赖都跑完了。
##02 备份这个临时分区，参照一下sql模板在即席备份数据，注意修改工号，时间等。表名的格式严格按照tmp_工号_日期_xxx。
------------------------------
  CREATE TABLE IF NOT EXISTS adhoctemp.tmp_xwx705275_20190402_dws_xxx_dm
  AS
  SELECT * from xxx where pt_d='20190402';
------------------------------
##03 如果是小时表，则不需要做以上操作。只需要等变更完成，观察下一个周期的执行情况即可
##04 待变更完成群里会通知，这时需要重做之前的历史分区【一般不用管】
##05 首先保证tcc执行完成，然后查询数据要正常。


-- 累成全量表
insert into dwd_xxx_ds
select
     col1
    ,col2
from dwd_xxx_ds_$date t1  -- 今天的增量数据
union all
select
     col1
    ,col2
from dwd_xxx_ds t2  
where pt_d='$last_date'  -- 昨天的全量数据
 and not exists
 (
    select 1 from dwd_xxx_ds_$date t3 where t3.pk=t2.pk
 )
;

--比较新旧数据量差别
select count(1)
from
(select imei from adhoctemp.tmp_xwx705275_20190513_dws_device_service_active_dm_hispace) old
left join
(
    select imei
    from dws_device_service_active_dm_hicloud
    where pt_d='20190513' and pt_service = 'hispace'
) new
on if(isempty(old.imei),'',old.imei)=if(isempty(new.imei),'',new.imei)
where isempty(new.imei)
;

-- 新增分区字段的方法
1、使用temp脚本将最近30天的数据手动刷到temp表。
2、手动刷完，停止temp任务
3、将原来的usage_dm.sql脚本备份为usage_dm_bak.sql
   上传新脚本usage_dm.sql到现网CDM目录【保证usage_dm任务能够执行usage_dm.sql这个脚本】
   移动数据：hadoop fs -mv hdfs://xxx/usage_dm  hdfs://xxx/usage_dm_bak
   重命名，将bak表的数据指向bak目录
     alter table usage_dm rename to usage_dm_bak;
     alter table usage_dm_bak set location hdfs://xxx/usage_dm_bak
   修复usage_dm_bak的分区【此时还是只有pt_d一个分区字段】
         beeline -e 
         "
           ALTER TABLE usage_dm_bak DROP PARTITION(pt_d='$date');
           MSCK REPAIR TABLE usage_dm_bak PARTITION(pt_d='$date');
         "
4、重新建带新分区字段的表，并将temp表中刷新后的带有新分区字段的数据移动到新的usage_dm表【移动数据很快】。
5、重刷1个月以前的分区


-- 如何验证tb_2是tb_1的子集？？？
select count(1) non_child_set_cnt -- 非子集数量
from tb_2
where not exists 
(
    select 1
    from tb_1
    where 
      tb_1.field1=tb_2.field1
      and tb_1.field2=tb_2.field2
)


-- 测试row_number() 中如果creat_time为空，如果降序排列，空值在最后；如果升序，空值在最前；
select 
     did
    ,imei
    ,channel
    ,push_token
    ,creat_time
    ,first_creat_time
    -- 按照从最近create_time到以前的顺序排列
    ,ROW_NUMBER() over (partition by did,channel order by creat_time DESC) as rn           
from dwd_ref_push_token_user_snap_ds
where pt_d='20190610' and uninstall_flg='0' and !isempty(channel) and did='00117f04-abac-451e-a6d5-490dc06eb7ab' and channel='com.huawei.android.hwouc'
limit 10;


-- hive参数优化
  -- 优化 group by 引起的数据倾斜，代价是通过2个job【job_1随机分配数据,部分聚合；job_2进行最终聚合】
  set hive.map.aggr=true;
  set hive.groupby.skewindata=true;

  -- 调整内存 【注意：map.memory.mb指的是container的内存】 
  set mapreduce.map.java.opts=-Xmx2048m(默认参数，表示jvm堆内存,注意是mapreduce不是mapred)
  set mapreduce.map.memory.mb=2304(container的内存,任务总内存）
  -- 完整调整堆内存
  set mapreduce.map.java.opts=-Xmx3276M -Djava.net.preferIPv4Stack=true；
  set mapreduce.reduce.java.opts=-Xmx3276M -Djava.net.preferIPv4Stack=true; 

  -- 涉及CombineInputFormat，将一个目录的所有文件作为一个map
  mapreduce.input.fileinputformat.split.maxsize
  mapreduce.input.fileinputformat.split.minsize.per.node
  mapreduce.input.fileinputformat.split.minsize.per.rack
  
  -- 调整Application Master参数
  set yarn.app.mapreduce.am.resource.mb=8192;
  set yarn.app.mapreduce.am.resource.cpu-vcores=4;
  set yarn.app.mapreduce.am.command-opts=-Xmx6553m -XX:CMSFullGCsBeforeCompaction=1 -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -verbose:gc;
  
-- spark参数优化

spark.sql.shuffle.partitions=2000 -- shuffle分区数为2000

spark-beeline -e "

set hive.execution.engine=spark;
set spark.eventLog.enable=true;
set spark.executer.memory=20g;
set spark.num-executer=100;
set spark.executer.cores=20;
set spark.driver.memory=4g;
set spark.driver.cores=4;
set spark.serializer=org.apache.spark.serializer.KryoSerializer;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
use bicoredata;

...
"

-- 数据倾斜
    大表关联大表 例如：事实表fact关联维度表dim_store（某几个维度对应的事实表中的数据特别多，造成对应的reduce执行时间慢）
    将相应的fact表中特定key取出来，每条记录中的key随机变为 key_rand(1~10) -- 可以通过group by key having count(key)>10000 得到对应数据特别多的key
    将dim_store中特定的几个key取出来，假设每个key都变为 [key_1,key_2, ... key_10]
    这样就将大数据量随机分散到10个不同的reduce，减少了数据倾斜
    



-- 即席查询环境下通过现网已有的表创建临时表，用于测试各个字段
create table if not exists adhoctemp.tmp_dws_xxx_dm
as
select 
    AESEncrypt4AD(server_node)    AS server_ip_addr
    ,product                      AS prod
from dws_xxx_dm
where pt_d='20190401';


select count(*)
from tmp_dws_xxx_dm;

drop table if exists tmp_dws_xxx_dm;


##变更验证方法:
##01 变更验证前，需要选取一个历史分区用于验证。尽量选一个星期左右的，然后查询反向依赖尽量保证所有的反向依赖都跑完了。
##02 备份这个临时分区，参照一下sql模板在即席备份数据，注意修改工号，时间等。表名的格式严格按照tmp_工号_日期_xxx。
##CREATE TABLE IF NOT EXISTS adhoctemp.tmp_dwx561911_20190402_t1
##as
##SELECT * from xxx where pt_d='';
##
##03 如果是小时表，则不需要做以上操作。只需要等变更完成，观察下一个周期的执行情况即可
##04 待变更完成群里会通知，这时需要重做之前的历史分区
##05 首先保证tcc执行完成，然后查询数据要正常。

-- 备份数据
create table if not exists temp.tmp_xwx705275_20190501_dwd_gps
as
select *
from device_ds
where pt_d='20190502' and pt_service='gps';

-- 验证新数据
select * from device_ds where pt_d='20190502' and pt_service='gps' limit 10;

-- 比对数据
select
  count(1)
from
(
    select * from temp.tmp_xwx705275_20190501_dwd_gps
) old
left join
(
    select * from device_ds where pt_d='20190501' and pt_service='gps'
) new
on if(isempty(old.imei),'0',old.imei)=if(isempty(new.imei),'0',new.imei)  
    and if(isempty(old.tcsm_first_start_region_cd),'0',old.tcsm_first_start_region_cd)=if(isempty(new.tcsm_first_start_region_cd),'0',new.tcsm_first_start_region_cd)
where isempty(new.imei);




-- 创建文本格式的表	
CREATE EXTERNAL TABLE `dwd_loc_ds`(	
`location_src_1` string COMMENT 'ip地址1', 	
`location_src_2` string COMMENT 'ip地址2', 	
`ip_src_name` string COMMENT 'ip来源名称')	
COMMENT 'IPV4地址类型库'	
ROW FORMAT SERDE 	
'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe' 	
WITH SERDEPROPERTIES ( 	
'field.delim'='|', 	
 'line.delim'='\n', 	
 'serialization.format'='|') 	
 STORED AS INPUTFORMAT 	
 'org.apache.hadoop.mapred.TextInputFormat' 	
 OUTPUTFORMAT 	
 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'	
 LOCATION	
 'hdfs://nscdm/AppData/BIProd/UDF/dwd_loc_gx_ip_type_udf_ds'	
 TBLPROPERTIES (	
 'COLUMN_STATS_ACCURATE'='false', 	
 'numFiles'='1', 	
 'numRows'='-1', 	
 'orc.compress'='ZLIB', 	
 'rawDataSize'='-1', 	
 'totalSize'='17175413', 	
 'transient_lastDdlTime'='1562054563');
 
 
CREATE EXTERNAL TABLE IF NOT EXISTS biods.ods_game_dynamic_tab_view_log_dm
(
    info_date                           string
    ,imei                               string
    ,user_id                            bigint
    ,service_type                       string
    ,method_name                        string
    ,uri                                string
    ,package_name                       string
    ,app_id                             string
    ,`timestamp`                        string COMMENT '时间戳'
    ,sdkversioncode                     string COMMENT 'sdkVersionCode'
    ,sdkversionname                     string COMMENT 'sdkVersionName'
    ,versioncode                        string COMMENT '游戏中心versionCode'
    ,versionname                        string COMMENT '游戏中心versionName'
    ,statkey                            string COMMENT '浮标弹框'
    ,gsource                            string COMMENT '来源'
    ,accountzone                        string COMMENT '用户服务地国家码'
    ,directory                          string COMMENT '可追溯路径'
    ,deviceidtype                       string COMMENT '设备标识类型'
    ,oaid                               string COMMENT 'Open Anonymous ID'
    ,istrackingenabled                  string COMMENT '广告开关标识'
)
PARTITIONED BY (
pt_d string)
ROW FORMAT SERDE
'org.apache.hadoop.hive.ql.io.orc.OrcSerde'
WITH SERDEPROPERTIES (
'field.delim'='|',
'line.delim'='\n',
'serialization.format'='|')
STORED AS INPUTFORMAT
'org.apache.hadoop.hive.ql.io.orc.OrcInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat'
LOCATION
'hdfs://nsods/AppData/BIProd/ODS/GAME/ODS_GAME_DYNAMIC_TAB_VIEW_LOG_DM'
TBLPROPERTIES (
'COLUMN_STATS_ACCURATE'='false',
'last_modified_by'='BICoreData',
'last_modified_time'='1525428996',
'numFiles'='0',
'numRows'='-1',
'orc.compress'='zlib',
'rawDataSize'='-1',
'totalSize'='0',
'transient_lastDdlTime'='1525428996');
 
 -- 将本地数据导入到hdfs上
 hadoop fs -put local_data hdfs://nscdm/dest/path
 
 -- hdfs上的路径，本地路径好像不能使用
 load data local inpath '/tmp/output/ods_action_dm' 
 overwrite into table db.dwd_app_action_hm partition (pt_d='20190429',pt_h='02');
 
 -- 增加字段，不仅变更新分区的表结构，同时变更旧分区的表结构
alter table db.dwd_music_hm add columns
(
    ip           VARCHAR(128)   COMMENT '响应ip'
) cascade;
