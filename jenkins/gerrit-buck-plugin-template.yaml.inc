- job-template:
    name: 'plugin-{plugin}-{branch}'
    project-type: freestyle
    description: "Plugin {plugin} {branch} branch build with BUCK\n"
    logrotate:
      numToKeep: 5
      artifactNumToKeep: 5
    properties:
       - authorization:
           anonymous:
             - job-discover
             - job-read
             - job-extended-read
    scm:
      - git:
         url: https://gerrit.googlesource.com/gerrit/plugins/{plugin}
         branches:
           - origin/{branch}
    triggers:
      - pollscm: 'H/5 * * * *'

    builders:
      - shell:
         !include-raw-escape gerrit-buck-build-plugin.sh
    publishers:
      - archive:
         artifacts: 'buck-out/gen/{plugin}.jar'

