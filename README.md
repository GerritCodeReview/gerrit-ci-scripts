# Gerrit CI scripts

## Providing jobs

This project uses Jenkins Jobs Builder [1] to generate jobs from yaml descriptor
files.

To add new jobs reuse existing templates, defaults etc. as much as possible.
E.g. adding a job to build an additional branch of a project may be as easy as
adding the name of the branch to an existing project.

To ensure well readable yaml-files, use yamllint [2] to lint the yaml-files.
Yamllint can be downloaded using Python Pip:

```sh
pip3 install yamllint
```

To run the linter, execute this command from the project's root directory:

```sh
yamllint -c yamllint-config.yaml jenkins/**/*.yaml
```

Yamllint will not fix detected issues itself.

[1] https://docs.openstack.org/infra/jenkins-job-builder/index.html
[2] https://pypi.org/project/yamllint/
