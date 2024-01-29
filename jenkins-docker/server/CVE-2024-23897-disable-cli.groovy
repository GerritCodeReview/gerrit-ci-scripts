/*
The MIT License

Copyright (c) 2024, CloudBees, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// Disable CLI access over HTTP
def removal = { lst ->
  lst.each { x -> if (x.getClass().name?.contains("CLIAction")) lst.remove(x) }
}
def j = jenkins.model.Jenkins.get();
removal(j.getExtensionList(hudson.cli.CLIAction.class))
removal(j.getExtensionList(hudson.ExtensionPoint.class))
removal(j.getExtensionList(hudson.model.Action.class))
removal(j.getExtensionList(hudson.model.ModelObject.class))
removal(j.getExtensionList(hudson.model.RootAction.class))
removal(j.getExtensionList(hudson.model.UnprotectedRootAction.class))
removal(j.getExtensionList(java.lang.Object.class))
removal(j.getExtensionList(org.kohsuke.stapler.StaplerProxy.class))
removal(j.actions)

println "Done!"
