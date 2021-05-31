const { ipcRenderer } = require("electron");

document.addEventListener("DOMContentLoaded", () => {
    const queries = new URLSearchParams(location.search);

    document.title = document.getElementById("hero-title").innerText =
        queries.get("title");

    document.getElementById("currentVersion").innerText =
        queries.get("version");

    const state = document.getElementById("status");

    ipcRenderer.on("checking-for-update", (e) => {
        state.innerHTML = `Checking for update...`;
    });

    ipcRenderer.on("new-update", (e, version) => {
        state.innerHTML = `New version found <b>${version}</b>!`;
    });

    ipcRenderer.on("download-progress", (e, progress) => {
        state.innerHTML = progress;
    });

    ipcRenderer.on("update-downloaded", (e) => {
        state.innerHTML = "Updated has been downloaded!";
    });

    ipcRenderer.on("error", (e, err) => {
        state.innerHTML = `Error: <b>${err}</b>!`;
    });
});
