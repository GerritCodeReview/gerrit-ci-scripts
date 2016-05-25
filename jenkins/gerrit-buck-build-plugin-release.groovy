import jenkins.model.Jenkins
import java.util.regex.*
import hudson.plugins.git.*
import org.eclipse.jgit.transport.RemoteConfig
import org.eclipse.jgit.transport.URIish

def buildPlugin(name, uri, branch) {
  // cd build.workspace
  // git clone uri plugins/name
  // cd plugins/name; git checkout branch
  // buck build plugins/name
  // ignore failure
  StringBuffer out = new StringBuffer()
  StringBuffer err = new StringBuffer()

  def clone = ["git", "clone", uri, "plugins/${name}"]
  def checkout = ["git", "checkout", "stable-${branch}"]
  def buckBuild = ["buck", "build", "plugins/${name}"]

  Process proc = clone.execute(null, new File(build.workspace))
  proc.waitForProcessOutput(out, err)
  proc = checkout.execute(null, new File(build.workspace, "plugins/${name}"))
  proc.waitForProcessOutput(out, err)
  proc = buckBuild.execute(null, new File(build.workspace))
  proc.waitForProcessOutput(out, err)

  println "Plugin ${name} build output:"
  println out.toString()
  println "Plugin ${name} build stderr:"
  println err.toString()
} 

Pattern tagRegex = ~/v(\d+\.\d+)/
Pattern pluginRegex = ~/plugin-(.*?)-(?<!mvn-)stable-(\d+\.\d+)/
//def build = Thread.currentThread().executable

println "Building branch ${build.envVars.GIT_BRANCH}"

def tagMatch = build.envVars.GIT_BRANCH =~ tagRegex
if (tagMatch) {
  def tag = tagMatch.group(1)

  for (item in Jenkins.instance.items) {
    match = item =~ pluginRegex
    if (match) {
      scm = item.scm
      name = match.group(1)
      branch = match.group(2)
      println "Checking plugin ${name} on ${branch}"
      if (branch != tag) {
        continue
      }
      if (scm instanceof hudson.plugins.git.GitSCM) {
        for (RemoteConfig cfg : scm.getRepositories()) {
          if (cfg.getName() == "origin") {
            for (URIish uri : cfg.getURIs()) {
              buildPlugin(name, uri.toString(), branch)
            }
          }
        }
      }
    }
  }
}

