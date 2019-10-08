// Copyright (C) 2019 The Android Open Source Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
