import azureml.core
from azureml.core import Dataset, Workspace, Experiment
from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core import Workspace, Datastore, Dataset
from azureml.core.authentication import AzureCliAuthentication

cli_auth = AzureCliAuthentication()


ws =  Workspace.get(name = "loanmodel913837", subscription_id = '35af589a-ac6f-43a2-af98-6b8a1684f1f3', resource_group = 'ODL-manymodels-913837', auth = cli_auth)


datastore_name = 'sbadata'


datastore = Datastore.get(ws, datastore_name)

datastore_paths = [(datastore, 'part-merged.csv')]



weather_ds = Dataset.Tabular.from_delimited_files(path=datastore_paths)

weather_ds.register(ws,'sbadatset123')
