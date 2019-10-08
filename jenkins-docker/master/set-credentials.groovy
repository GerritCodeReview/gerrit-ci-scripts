import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;

new File("/var/jenkins_home/.netrc").eachLine { line ->
  def lineParts = line.trim().split()
  if (lineParts.size() > 0) {
    def machine = lineParts[1]
    def user = lineParts[3]
    def pass = lineParts[5]
    println "Setting password for user $user on machine $machine"
    Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(machine, ".netrc credentials for $machine", user, pass)
    SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)
  }
}
