
TGZ=$1
BASE=$2

cp $TGZ $BASE
cd $BASE
tar xzf `basename $TGZ` --strip-components=1

#HACK HACK HACK clobbering file
echo "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_67/" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo "export YARN_EXAMPLES=/home/ian/hadoop_dist/share/hadoop/mapreduce" > /etc/profile.d/yarn.sh
source /etc/profile.d/yarn.sh

#HACK HACK HACK might've done that before
sudo groupadd hadoop
 
#HACK HACK HACK might've done that before
useradd -g hadoop yarn
useradd -g hadoop hdfs
useradd -g hadoop mapred

mkdir data
cd data
mkdir hdfs
mkdir hdfs/nn
mkdir hdfs/snn
mkdir hdfs/dn
cd ..

mkdir log
mkdir log/hadoop/
mkdir log/hadoop/yarn

mkdir logs
         
echo "<configuration> <property> <name>fs.default.name</name> <value>hdfs://localhost:9000</value> </property> <property> <name>hadoop.http.staticuser.user</name> <value>hdfs</value> </property> </configuration>" > $BASE/etc/hadoop/core-site.xml 

echo "<configuration><property> <name>dfs.replication</name> <value>1</value> </property> <property> <name>dfs.namenode.name.dir</name> <value>file:$BASE/data/hdfs/nn</value> </property> <property> <name>fs.checkpoint.dir</name> <value>file:$BASE/data/hdfs/snn</value> </property> <property> <name>fs.checkpoint.edits.dir</name> <value>file:$BASE/data/hdfs/snn</value> </property> <property> <name>dfs.datanode.data.dir</name> <value>file:$BASE/data/hdfs/dn</value> </property> </configuration>" > $BASE/etc/hadoop/hdfs-site.xml 

cp $BASE/etc/hadoop/mapred-site.xml.template $BASE/etc/hadoop/mapred-site.xml
echo "<configuration> <property> <name>mapreduce.framework.name</name> <value>yarn</value> </property> </configuration>" > $BASE/etc/hadoop/mapred-site.xml

echo "<configuration> <property> <name>yarn.nodemanager.aux-services</name> <value>mapreduce_shuffle</value> </property> <property> <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name> <value>org.apache.hadoop.mapred.ShuffleHandler</value> </property> </configuration>" > $BASE/etc/hadoop/yarn-site.xml
 
chown yarn:hadoop $BASE -R
chown hdfs:hadoop $BASE/data -R
chmod g+w $BASE/logs

#HACK HACK HACK should work, I am assuming that setting at eof overrides previous settings, but HACK
echo "export HADOOP_HEAPSIZE=500" >> $BASE/etc/hadoop/hadoop-env.sh
echo "export HADOOP_NAMENODE_INIT_HEAPSIZE=500" >> $BASE/etc/hadoop/hadoop-env.sh

#HACK HACK HACK should work, I am assuming that setting at eof overrides previous settings, but HACK
echo "export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=250" >> $BASE/etc/hadoop/mapred-env.sh

#HACK HACK HACK should work, I am assuming that setting at eof overrides previous settings, but HACK
echo "export JAVA_HEAP_MAX=-Xmx500m YARN_HEAPSIZE=500" >> $BASE/etc/hadoop/yarn-env.sh
 
su -c "$BASE/bin/hdfs namenode -format" hdfs
su -c "$BASE/sbin/hadoop-daemon.sh stop namenode" hdfs
su -c "$BASE/sbin/hadoop-daemon.sh stop secondarynamenode" hdfs
su -c "$BASE/sbin/hadoop-daemon.sh stop datanode" hdfs
su -c "$BASE/sbin/yarn-daemon.sh stop resourcemanager" yarn
su -c "$BASE/sbin/yarn-daemon.sh stop nodemanager" yarn

su -c "$BASE/sbin/hadoop-daemon.sh start namenode" hdfs
su -c "$BASE/sbin/hadoop-daemon.sh start secondarynamenode" hdfs
su -c "$BASE/sbin/hadoop-daemon.sh start datanode" hdfs
su -c "$BASE/sbin/yarn-daemon.sh start resourcemanager" yarn
su -c "$BASE/sbin/yarn-daemon.sh start nodemanager" yarn

sleep 10

jps

su -c "$BASE/bin/yarn jar $BASE/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.3.0-cdh5.1.2.jar pi 16 1000" hdfs
