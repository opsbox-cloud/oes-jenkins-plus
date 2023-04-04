#!/bin/bash

mkdir -p /var/log/supervisor/ 

_agentService=${AGENT_SERVICE:-jenkins-agent}

if [ -f /etc/supervisor/conf.d/${_agentService}.conf.disable ]; then
  mv /etc/supervisor/conf.d/${_agentService}.conf.disable /etc/supervisor/conf.d/${_agentService}.conf
fi

_cleanupPeriodic=${CLEANUP_PERIODIC:-weekly}

if [ -f /usr/local/bin/jenkins-clean-data ]; then
  ln -s /scripts/jenkins-clean-data /etc/periodic/${_cleanupPeriodic}/jenkins-clean-data
fi

# start superviosrd
supervisord --nodaemon --configuration /etc/supervisord.conf