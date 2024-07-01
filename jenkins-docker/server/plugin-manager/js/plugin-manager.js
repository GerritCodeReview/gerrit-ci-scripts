// Copyright (C) 2024 The Android Open Source Project
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

var app = angular.module('PluginManager', []).controller(
    'LoadInstalledPlugins',
    function($scope, $http, $location, $window) {
      var plugins = this;

      plugins.list = [];

      $scope.searchPlugin = '';

      $scope.branch = 'master';

      $scope.pluginIndexOf = function(pluginId) {
        var pluginIndex = -1

        angular.forEach(plugins.list, function(row, rowIndex) {
          if (row.id == pluginId) {
            pluginIndex = rowIndex
          }
        });

        return pluginIndex;
      }

      $scope.getBaseUrl = function () {
        // Using a relative URL for allowing to reach Gerrit base URL
        // which could be a non-root path when behind a reverse proxy
        // on a path location.
        // The use of a relative URL is for allowing a flexible way
        // to reach the root even when accessed outside the canonical web
        // URL (e.g. accessing on node directly with the hostname instead
        // of the FQDN)
        return window.location.pathname + '/../../../..';
      }

      $scope.refreshAvailable = function() {
        var pluginsBranch='Plugins-' + $scope.branch;
        $http.get($scope.getBaseUrl() + '/view/' + pluginsBranch + '/api/json', plugins.httpConfig)
            .then(
                function successCallback(response) {
                  plugins.list = [];

                  angular.forEach(response.data.jobs, function(plugin) {

                    const pluginNameRegex = /(module-|plugin-|ui-plugin-)(.*)-bazel.*/;
                    var pluginNameMatches = plugin.name.match(pluginNameRegex);
                    if (!pluginNameMatches) {
                       return;
                    }
                    var pluginName = pluginNameMatches[2];
                    $http.get($scope.getBaseUrl() + '/job/' + plugin.name + '/lastSuccessfulBuild/artifact/bazel-bin/plugins/' + pluginName + '/' + pluginName + '.json', plugins.httpConfig)
                         .then(function successCallback(pluginResponse) {
                      var currRow = $scope.pluginIndexOf(pluginName);
                      var currPlugin = currRow < 0 ? undefined
                          : plugins.list[currRow];

                      if (currPlugin === undefined) {
                        currPlugin = {
                          id : pluginName,
                          index_url : '',
                          version : ''
                        }
                      }
                      currPlugin.sha1 = plugin.sha1;
                      const uiPluginRegex = /(ui-plugin-)(.*)-bazel.*/;
                      var uiPluginNameMatches = plugin.name.match(uiPluginRegex);
                      var fileEnding = uiPluginNameMatches ? '.js' : '.jar';
                      currPlugin.url = $scope.getBaseUrl() + '/job/' + plugin.name + '/lastSuccessfulBuild/artifact/bazel-bin/plugins/' + pluginName + '/' + pluginName + fileEnding;
                      currPlugin.description = pluginResponse.data.description;

                      if (currRow < 0) {
                        plugins.list.push(currPlugin);
                      } else {
                        plugins.list[currRow] = currPlugin;
                      }
                      $http.get($scope.getBaseUrl() + '/job/' + plugin.name + '/lastSuccessfulBuild/artifact/bazel-bin/plugins/' + pluginName + '/' + pluginName + '.jar-version', plugins.httpConfig)
                           .then(function successCallback(pluginVersionResponse) {
                        currPlugin.version = pluginVersionResponse.data;
                      });
                    });
                  });
                }, function errorCallback(response) {
                });
      }

      plugins.login = function () {
        $window.location.href = 'https://gerrit-ci.gerritforge.com/securityRealm/commenceLogin?from=%2F';
      };

      $scope.refreshAvailable();
    });

app.config(function($httpProvider) {
  $httpProvider.defaults.headers.common = {
    'X-Gerrit-Auth' : '@X-Gerrit-Auth'
  };
});
