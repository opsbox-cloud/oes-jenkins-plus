#!/bin/bash 
set -eux
mkdir -p /var/log/supervisor/

if [ "x${ENABLE_JENKINS_AGENT}" != "x" ]; then
    if [ ! -f /etc/supervisor/conf.d/${ENABLE_JENKINS_AGENT}.conf.disable ]; then
        echo "--//ERR: no support"
        #exit 1
    fi

    mv /etc/supervisor/conf.d/${ENABLE_JENKINS_AGENT}.conf.disable /etc/supervisor/conf.d/${ENABLE_JENKINS_AGENT}.conf
fi

if [[ "x${CLEAN_DATA_PERIODIC}" != "x" ]]
then
    ln -s /scripts/jenkins-clean-data /etc/periodic/${CLEAN_DATA_PERIODIC}/jenkins-clean-data
fi

exec supervisord --nodaemon --configuration /etc/supervisord.conf
