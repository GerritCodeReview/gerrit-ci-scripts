package main

import "github.com/robfig/cron"
import "os"
import "os/exec"

func updateJobs() {
    cmd := exec.Command("/usr/local/bin/update-jobs.sh")
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    cmd.Run()
}

func main() {
    c := cron.New()
    c.AddFunc("@every 5m", func() { updateJobs() })
    c.Start()
    jenkins := exec.Command("/usr/local/bin/jenkins.sh")
    jenkins.Stdout = os.Stdout
    jenkins.Stderr = os.Stderr
    jenkins.Run()
    c.Stop()
}

