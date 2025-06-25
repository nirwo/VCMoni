I have a project to build a Vcenter Report webApp

1. it should first have a login screen to vcenter using python pyvmomi
2. post login it should load a modern bootstrap ui that would present the following

- VENTER OVERVIEW
- HOSTS
- VMs
- DATASTORES
- NETWORKS
- CLUSTERS

3. Below the overview , it should provide charts of each clusters utilization in regards of Memory , CPU , Storage free and used
4. should provide capacity calculator based on the logic of not allowed to use higher then 85% of the total resources , for example out of 112 cores allowed to use only 85% of it , same for memory and for storage
   important to mention this is to be calculation of Datastore cluster , Compute cluster , and not single ESX hosts

Vcenter session should be saved and not have a need to always insert credentials for smooth use

5. should provide a button to export the data to excel file

data should be kept in a csv or some offline db file without the need to pull all data from vcenter but to update only deltas, its important that every refresh makes sure everything is up to date, meaning if new vm was created, it needs to show it..

6. should provide a button to export the data to excel file
   webui should be build over npm ( vite ) and should be responsive and modern
