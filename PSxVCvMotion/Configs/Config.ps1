$cfg = @{} #Do not modify this line

#### MANDATORY PARAMETERS

# Informations about the source vCenter
$cfg.sourcevc = @{
    vc = 'srv-vcenter-01.example.com'
    user = 'administrator@vsphere.local'
    password = 'VMware1!'
}

# Information about the destination vCenter
$cfg.destinationvc = @{
    vc = 'srv-vcenter-02.example.com'
    user = 'administrator@vsphere.local'
    password = 'VMware1!'
}

# Cluster translation table
# List of source and destination clusters
# You can provide only one line
$cfg.cluster = @(
    @{source = 'CLUSTER01' ; destination = 'CLUSTER02'}
)

# List of VM matching the specified pattern and excluded VMs
# vm = '*' -> All VM selected
# vm = 'TEST*' -> All VM who's name starts with TEST
$cfg.vm = @{
    scope = '*'
    exclusion = @('VM01','VM02')
}

#### OPTIONAL PARAMETERS

# Portgroup translation table
# List of source and destination portgroups
# If the source portgroup is not on the list, the script will look at a destination portgroup with the same name 
$cfg.portgroup = @(
    @{source = 'PORTGROUP01'; destination = 'PORTGROUP03'}
    @{source = 'PORTGROUP02'; destination = 'PORTGROUP04'}
)

# Datastore translation table
# List of source and destination datastores
# If the source datastore is not on the list, the script will look at a destination datastore with the same name
# If the VM has multiple datastore, the first one is selected
# Selecting a datastore cluster as destination is not supported
$cfg.datastore = @(
    @{source = 'DATASTORE01'; destination = 'DATASTORE04'}
    @{source = 'DATASTORE02'; destination = 'DATASTORE05'}
    @{source = 'DATASTORE03'; destination = 'DATASTORE06'}
) 