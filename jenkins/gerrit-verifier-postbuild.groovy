def timedOut = manager.logContains("timed out")
if (timedOut)
{
    manager.buildAborted()
}
