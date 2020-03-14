
## hive字符串操作
### 截取子串
``` sql
substr('my_string', -1)    -- 截取最后一个字符
substr('my_string', 4)     -- 'string' 截取第4个字符到最后一个字符最为子串 【下标从1开始计数】
substr('my_string', 2, 5)  -- 截取从第2个字符开始的5个字符

substring_index('123.345.789', '.', -1)  -- '789' 截取'.'分割后的最后一个划分
substring_index('123.345.789', '.', -2)  -- '345.789'

instr('facebook', 'boo')   -- 5 下标从1开始计数

SELECT SUBSTR('{"key1":"0"}',INSTR('{"key1":"0"}','{"')+LENGTH('{"'),INSTR('{"key1":"0"}','":')-1-LENGTH('{"'));  -- 取json object的第一个key
```
--- 
### 正则表达式
#### 正则替换
```
注意：
    脚本中转义字符'\'使用'\\\\'；但是在beeline交互式环境和即席环境使用'\\'
    category_list='[{"value":"value1","key":"key1"},{"key":"key2"}]'
```
```sql

-- step1:去掉左右中括号
regexp_replace(category_list, '\\\\[|\\\\]', '');
-- step2:将 '},{' --> '}||{'
regexp_replace(step1, '\\\\},\\\\{', '\\\\}\\\\|\\\\|\\\\{');
-- step3:按照'||'进行分割，并进行一行转多行
select 
     t1.*
    ,get_json_object(t2,'$.key') as t2_key
    ,get_json_object(t2,'$.value') as t2_value
from t1 
     lateral view explode(split(step2, '\\\\|\\\\|')) t2 AS field;
-- 拼成大的json串
concat('{', CONCAT_WS('\,', collect_set(concat('\"', t2_key, '\"', ':', '\"', NVL(t2_value,''), '\"'))), '}');

-- *? 表示 最小匹配
-- str_exmaple = '红色//red;;;qqq绿色//green;;;qqq紫色//purple'
split(regexp_replace('str_exmaple', '//.*?\\\\;\\\\;\\\\;qqq', ','), '//')[0]
```
#### 正则提取


#### 正则匹配
如果 需要匹配整个字符串，一定要加入开始和结束符 '^pattern$'
--- 
### 日期格式化
```sql
-- 格式化日期 ==> 时间戳
unix_timestamp('2019-04-02','yyyy-MM-dd');
-- 时间戳 ==> 格式化日期
from_unixtime(150000323423, 'yyyy-MM-dd HH:mm:ss');
-- [UDF] unix_time时间戳 --> 'yyyy-MM-dd HH:mm:ss.SSS'
DateUtil(CAST(server_time AS BIGINT), 1, 'yyyy-MM-dd HH:mm:ss.SSS') AS server_time
```

---
## 窗口函数
```sql

last_value(field_1) -- 当order by后的字段类型为varchar时，会报错，如果是STRING时，没有问题
```



