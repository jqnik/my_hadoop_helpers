#!/bin/bash
reset && mvn clean && mvn package -Pdist -DskipTests -Dtar | tee build_output 2>&1
cd hadoop-maven-plugins
mvn clean && mvn install -DskipTests
cd ..
DIRS="hadoop-hdfs-project hadoop-common-project hadoop-mapreduce-project hadoop-yarn-project"
for dir in $DIRS
do
    cd $dir
    #Q: how to just rebuild ecplipse (i.e. mvn clean eclipse:eclipse)
    mvn eclipse:eclipse -DskipTests
    cd ..
done

# mvn eclipse:eclipse is broken in CDH5.1.0 and CDH5.1.2
# (“Request to merge when ‘filtering’ is not identical.”)
# The following hack brings the plugin version to 2.6, which fixes it
cd hadoop-yarn-project
# do I have to add -DdownloadSource / Javadocs every time? I hope I do not have to download every time...
#mvn org.apache.maven.plugins:maven-eclipse-plugin:2.6:eclipse -DdownloadSources=true -DdownloadJavadocs=true
mvn org.apache.maven.plugins:maven-eclipse-plugin:2.6:eclipse
cd ..
