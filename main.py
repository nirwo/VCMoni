import os
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import Optional
from dotenv import load_dotenv

from vmware.vapi.vsphere.client import create_vsphere_client  # type: ignore
import requests

load_dotenv()

VCENTER_SERVER = os.getenv("VCENTER_SERVER")
VCENTER_USER = os.getenv("VCENTER_USER")
VCENTER_PASSWORD = os.getenv("VCENTER_PASSWORD")

app = FastAPI(title="VCenter Report API")

app.mount("/static", StaticFiles(directory="static", html=True), name="static")


class LoginRequest(BaseModel):
    server: str
    username: str
    password: str


SESSION: Optional[str] = None


def get_client():
    global SESSION
    if SESSION:
        session = SESSION
    else:
        raise HTTPException(status_code=401, detail="Not logged in")

    return create_vsphere_client(server=VCENTER_SERVER, session=session)


@app.post("/login")
async def login(data: LoginRequest):
    session = requests.post(
        f"https://{data.server}/rest/com/vmware/cis/session",
        auth=(data.username, data.password),
        verify=False,
    )
    if session.status_code != 200:
        raise HTTPException(status_code=401, detail="Login failed")

    global SESSION, VCENTER_SERVER
    SESSION = session.json()["value"]
    VCENTER_SERVER = data.server
    return {"status": "ok"}


@app.get("/")
async def root():
    index_path = os.path.join("static", "index.html")
    return FileResponse(index_path, media_type="text/html")


from vcenter_client import (
    list_clusters,
    list_hosts,
    list_vms,
    list_datastores,
    capacity_calculator,
)

# API endpoints
@app.get("/overview")
async def overview(client=Depends(get_client)):
    clusters = list_clusters(client)
    hosts = list_hosts(client)
    vms = list_vms(client)
    datastores = list_datastores(client)

    return {
        "clusters": len(clusters),
        "hosts": len(hosts),
        "vms": len(vms),
        "datastores": len(datastores),
    }


@app.get("/clusters")
async def clusters(client=Depends(get_client)):
    clusters = list_clusters(client)
    data = []
    for c in clusters:
        # Actual utilization retrieval TBD
        util = {"cpu_pct": 50, "mem_pct": 60, "storage_pct": 40}
        item = {"name": c.name, **util, "capacity": capacity_calculator(util)}
        data.append(item)
    return data


@app.get("/hosts")
async def hosts(client=Depends(get_client)):
    hosts = list_hosts(client)
    # map minimal fields
    return [{"name": h.name, "cpu": h.cpu_count, "memory": h.memory_size_MiB, "status": h.connection_state} for h in hosts]


@app.get("/vms")
async def vms(client=Depends(get_client)):
    vms = list_vms(client)
    return [
        {
            "name": vm.name,
            "cpu": vm.cpu_count,
            "memory": vm.memory_size_MiB,
            "power_state": vm.power_state,
        }
        for vm in vms
    ]


@app.get("/datastores")
async def datastores(client=Depends(get_client)):
    dss = list_datastores(client)
    return [
        {
            "name": ds.name,
            "capacity_gb": round(ds.capacity / 1024**3, 1),
            "free_gb": round(ds.free_space / 1024**3, 1),
            "type": ds.type,
        }
        for ds in dss
    ]


@app.get("/networks")
async def networks(client=Depends(get_client)):
    nets = client.vcenter.Network.list()  # type: ignore
    return [{"name": n.name, "type": n.type} for n in nets]


@app.post("/capacity")
async def capacity(payload: dict):
    return capacity_calculator(payload)


@app.get("/export")
async def export_report():
    # TODO: Generate Excel and return FileResponse
    return {"todo": True}

