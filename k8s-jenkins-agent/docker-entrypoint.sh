#!/bin/sh

if [ -f "/init" ]; then
    /init &
fi

wget -O agent.jar $JENKINS_URL/jnlpJars/agent.jar && java -Xms4096m -Xmx4096m -Dhudson.remoting.Launcher.pingIntervalSec=-1 -jar /home/jenkins/agent/agent.jar -jnlpUrl $JENKINS_URL/computer/$JENKINS_NAME/jenkins-agent.jnlp -secret $JENKINS_SECRET -noReconnect -workDir /home/jenkins/agent
