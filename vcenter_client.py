"""vCenter interaction helper using pyvmomi.
All calls expect an authenticated vsphere_client from vapi SDK.
If VCENTER_SERVER env vars missing or session invalid, raise.
"""
from typing import List, Dict
from functools import lru_cache

from vmware.vapi.vsphere.client import VSphereClient  # type: ignore


def list_clusters(client: VSphereClient):
    return client.cluster.List()  # type: ignore


def list_hosts(client: VSphereClient):
    return client.host.List()  # type: ignore


def list_vms(client: VSphereClient):
    return client.vcenter.VM.list()  # type: ignore


def list_datastores(client: VSphereClient):
    return client.vcenter.Datastore.list()  # type: ignore


# Placeholder capacity calculator

def capacity_calculator(utilization: Dict[str, float]):
    """Given utilization percentages per resource returns remaining capacity respecting 85% max."""
    result = {}
    for key, used_pct in utilization.items():
        allowed = 85.0
        remaining_pct = max(0.0, allowed - used_pct)
        result[key] = remaining_pct
    return result
