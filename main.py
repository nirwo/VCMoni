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


# Placeholder endpoints for frontend data
@app.get("/overview")
async def overview(client=Depends(get_client)):
    # TODO: Implement actual retrieval from vCenter
    return {"clusters": 0, "hosts": 0, "vms": 0, "datastores": 0}


@app.get("/export")
async def export_report():
    # TODO: Generate Excel and return FileResponse
    return {"todo": True}

