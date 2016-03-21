#介绍一下如何使用CloudInsight-Ruby-SDK监控业务数据

> [Cloud Insight](http://www.oneapm.com/ci/feature.html) (次世代系统监控工具):
集监控、管理、协作、计算、可视化于一身，减少在系统监控上的人力和时间成本投入，让运维工作变得更加高效、简单。


###SDK使用步骤
  1. 安装[Cloud Insight](http://www.oneapm.com/ci/feature.html)探针，见[文档](http://docs-ci.oneapm.com/quick-start/)。
  2. 获取业务数据，例如获取[Ruby-China](https://ruby-china.org/topics)的**回帖活跃度**。
  3. 在```Gemfile```加入 ```gem 'oneapm_ci', '0.0.1'```。
  4. 运行 ```bundle install```, 具体脚本如下：
  5. 
  
  

5. 需要定时向探针传送数据可以参考[awesonme-ruby推荐的工具](https://github.com/markets/awesome-ruby#scheduling)。
