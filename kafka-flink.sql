
-- Flink容错机制 （ABS asynchronous barrier snapshot 异步屏障快照 -- checkpoint）
    barrier 有Flink生成，在数据进入计算集群是向数据流中加入barrier_n，通过在对应的snapshot中记录进度信息。当sink operator从所有输入流中收到barrier_n时，确认这个快照被标记完成。
    
    存储计算分离
    当节点发生故障，Flink自动重启Job，并从最近的checkpoint恢复

-- watermark 窗口
watermark：解决乱序事件流，常用办法是定义一个最大允许乱序的时间，水位线是源头事件的一个隐藏时间戳，一个水位线的时间戳t表明：-- 早于水位线 t 的事件 都已经到达了。
    水印可抽象地表示成函数 f(Process_time)=Event_time，即我们能够在处理时间点Process_time判定事件时间推进到了Event_time【事件时间<处理时间】。
    watermark的作用是决定窗口的删除时间。
    例如：使用基于事件时间的窗口，5min中的翻滚窗口，允许延迟1min，Flink将在12:00~12:05之间且落入此间隔时间戳的第一个元素到达时创建窗口，并将在watermark超过12:06时删除窗口。
    
    
    
    
-- Parquet
    数据存储格式
    数据模型[内存中的数据表示] avro、thrift、protocol-buffer、hive-serde
    
  row group
    column chunk
        page
  footer
  
-- 日志框架 slf4j是门面模式， log4j和logback是日志库【具体实现】
    slf4j + log4j
    slf4j + logback
  
  
-- Kafka 发布订阅模式
    Topic + Partition + Leader Replica + Follower Replica
    客户端Producer
    客户端Consumer
    服务器程序Broker：负责接收和处理客户端发送过来的请求，以及对消息进行持久化
    
    持久化消息：消息日志 磁盘 Log Segment 追加最新日志段，写满一个日志段，切分出新的日志段，封存老日志段
    
    
-- Kafka+Flink 实现端到端的exactly once
    Kafka的事务和生产幂等
    Flink的barrier实现的checkpoint机制

    
消息队列 重发未成功的消息 可能会出现重复消息 
    在消费端做幂等来克服重复消息

流计算平台 存储计算分离 计算任务的状态保存在分布式存储系统中
    每个子任务将状态分离出去之后，变成无状态节点，如果宕机，集群中任意节点都可以替代
持久化流动的数据
    重启整个计算任务，从数据源回溯到特定位置的数据，重新计算

Flink Exactly Once 【数据只被计算一次】 
    checkpoint ：保存子任务的临时计算状态数据  +  数据源中的位置信息
当一个 Barrier 流过所有计算节点，流出计算集群后，一个checkpoint也就保存完成。
    保证checkpoint中记录的恢复位置 和 计算节点状态 完全对应

    
-- 消息队列
    队列和Topic的区别：一份消息能否被消费多次
    Kafka 每秒处理几十万条消息，设计上大量使用了批量和异步的思想
    
  检测消息丢失的方法：利用消息队列序号的有序性，Consumer和topic中的partition最好一一对应
