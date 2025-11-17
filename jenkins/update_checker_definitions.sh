curl -X POST -n -v https://gerrit-review.googlesource.com/a/plugins/checks/checkers/gerritforge-gcp%3Arbe-a6a0e4682515f3521897c5f950d1394f4619d928 \
  -H 'Content-Type: application/json; charset=UTF-8' \
-d '{
    "name": "RBE GCP Build/Tests",
    "description": "Builds the code base and executes unit/integration tests on GCP RBE",
    "repository": "gerrit",
    "query": "(not dir:polygerrit-ui) AND (branch:stable-3.11 OR branch:stable-3.12 OR branch:stable-3.13 OR branch:master)",
    "blocking": []
  }'

curl -X POST -n -v https://gerrit-review.googlesource.com/a/plugins/checks/checkers/gerritforge%3Arbe-a6a0e4682515f3521897c5f950d1394f4619d928  \
  -H 'Content-Type: application/json; charset=UTF-8' -d '
  {
    "name": "RBE BB Build/Tests",
    "description": "Builds the code base and executes unit/integration tests on BuildBuddy RBE",
    "repository": "gerrit",
    "query": "(not dir:polygerrit-ui)  AND -age:1w AND (branch:stable-3.11 OR branch:stable-3.12 OR branch:stable-3.13 OR branch:master)",
    "blocking": []
  }'

curl -X POST -n -v https://gerrit-review.googlesource.com/a/plugins/checks/checkers/gerritforge%3Anotedb-a6a0e4682515f3521897c5f950d1394f4619d928  \
  -H 'Content-Type: application/json; charset=UTF-8' -d '
  {
    "name": "Build/Tests",
    "description": "Builds the code base and executes unit/integration tests",
    "repository": "gerrit",
    "query": "(not dir:polygerrit-ui) AND (branch:stable-3.11 OR branch:stable-3.12 OR branch:stable-3.13 OR branch:master)",
    "blocking": []
  }'

curl -X POST -n -v https://gerrit-review.googlesource.com/a/plugins/checks/checkers/gerritforge%3Apolygerrit-a6a0e4682515f3521897c5f950d1394f4619d928  \
  -H 'Content-Type: application/json; charset=UTF-8' -d '
  {
    "name": "PolyGerrit UI Tests",
    "description": "Executes unit/integration tests for PolyGerrit UI",
    "repository": "gerrit",
    "query": "(dir:polygerrit-ui OR file:WORKSPACE) AND (branch:stable-3.11 OR branch:stable-3.12 OR branch:stable-3.13 OR branch:master)",
    "blocking": []
  }'

curl -X POST -n -v https://gerrit-review.googlesource.com/a/plugins/checks/checkers/gerritforge%3Acodestyle-a6a0e4682515f3521897c5f950d1394f4619d928  \
  -H 'Content-Type: application/json; charset=UTF-8' -d '
  {
    "name": "Code Style",
    "description": "Executes Code Style tests",
    "repository": "gerrit",
    "query": "branch:stable-3.11 OR branch:stable-3.12 OR branch:stable-3.13 OR branch:master",
    "blocking": []
  }'
