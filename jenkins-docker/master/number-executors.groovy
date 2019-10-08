import hudson.model.*;
import jenkins.model.*;


Thread.start {
      sleep 10000
      println "--> setting maximum number of executors on master"
      Jenkins.instance.setNumExecutors(10)
      Jenkins.instance.reload()
}
