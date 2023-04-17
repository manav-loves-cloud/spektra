import azureml.core
from azureml.core import Dataset, Workspace, Experiment
from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core import Workspace, Datastore, Dataset
from azureml.core.authentication import AzureCliAuthentication

cli_auth = AzureCliAuthentication()


ws =  Workspace.get(name = "abc", subscription_id = 'def', resource_group = 'hij', auth = cli_auth)


datastore_name = 'sbadata'


datastore = Datastore.get(ws, datastore_name)

datastore_paths = [(datastore, 'part-merged.csv')]



weather_ds = Dataset.Tabular.from_delimited_files(path=datastore_paths)

weather_ds.register(ws,'SBADATA')
