#!/bin/bash
sed -i -e "s/#OAUTH-ID#/$OAUTH_ID/g" $JENKINS_REF/config.xml
sed -i -e "s/#OAUTH-SECRET#/$OAUTH_SECRET/g" $JENKINS_REF/config.xml
