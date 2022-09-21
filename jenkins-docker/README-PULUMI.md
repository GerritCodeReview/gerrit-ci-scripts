# Project structure

Each component migrate to a Pulumi managed stack will have the relative code contained in the `<componentName>-pulumi` directory, i.e.: `server-pulumi`.

Each component will have its owns stacks (`dev` and `prod`).

# Stack handling

*NOTE:* To perform any operation on stack you need access to the `Gerrit` GCP project.

To spin-up a stack `cd` into the component you are interested and type:

`pulumi up -s <stackName>`

To destroy a stack type:

`pulumi destroy -s <stackName>`

The stack state is held in a bucket called `gs://gerrit-<componentName>-pulumi-state`, i.e.: ``gs://gerrit-jenkins-server-pulumi-state``

# Development setup

Active the python virtual environment as follow:

`source venv/bin/activate`

Now you can run `pip install -r requirements.txt` to install all the needed packages.

## Code formatting

To format the code run `yapf -ir --exclude 'venv/' .`
