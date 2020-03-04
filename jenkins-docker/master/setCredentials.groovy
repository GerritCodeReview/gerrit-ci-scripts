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

/*
The '/var/jenkins_home/.secrets'-file should have the following structure:

{
  "example": {
    "id": "example.com",
    "type": "string",
    "string": "secret",
    "description": "a secret"
  },
  "example2": {
    "id": "exampleUserPassword",
    "type": "UserPassword",
    "user": "admin",
    "password": "secret",
    "description": "another secret"
  },
}
*/

import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;
import groovy.json.JsonSlurper;
import hudson.util.Secret;
import java.io.FileNotFoundException;
import org.jenkinsci.plugins.plaincredentials.impl.*;

def addCredentials(Credentials c) {
  SystemCredentialsProvider
    .getInstance()
    .getStore()
    .addCredentials(Domain.global(), c)
}

def addStringCredential(id, string, description){
  Secret secret = Secret.fromString(string)
  addCredentials(
    (Credentials) new StringCredentialsImpl(
      CredentialsScope.GLOBAL,
      id,
      description,
      secret))
  println "Adding secret string with credential id $id"
}

def addUserPasswordCredential(id, user, password, description){
  addCredentials(
    (Credentials) new UsernamePasswordCredentialsImpl(
      CredentialsScope.GLOBAL,
      id,
      description,
      user,
      password))
  println "Setting password for user $user to credential id $id"
}

def extractCredFromFile(filePath){
  def jsonSlurper = new JsonSlurper()
  def fileContents = jsonSlurper.parse(new File(filePath))

  fileContents.each { name, credential ->
    switch(credential.type.toLowerCase()) {
      case "userpassword":
        addUserPasswordCredential(
          credential.id,
          credential.user,
          credential.password,
          credential.description)
        break
      case "string":
        addStringCredential(
          credential.id,
          credential.string,
          credential.description)
        break
    }
  }
}

try {
  extractCredFromFile('/var/jenkins_home/.secrets')
} catch(FileNotFoundException e) {
  println "Couldn't find .secrets file"
}


try {
  new File("/var/jenkins_home/.netrc").eachLine { line ->
    def lineParts = line.trim().split()
    if (lineParts.size() > 0) {
      def machine = lineParts[1]
      def user = lineParts[3]
      def pass = lineParts[5]
      println "Setting password for user $user on machine $machine"
      Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, machine, ".netrc credentials for $machine", user, pass)
      SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)
    }
  }
} catch(FileNotFoundException e) {
  println "Couldn't find .netrc file"
}
