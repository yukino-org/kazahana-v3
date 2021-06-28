const { ipcRenderer } = require("electron");

document.addEventListener("DOMContentLoaded", () => {
    const queries = new URLSearchParams(location.search);

    document.title = document.getElementById(
        "hero-title"
    ).innerText = queries.get("title");

    document.getElementById("currentVersion").innerText = queries.get(
        "version"
    );

    const state = document.getElementById("status");
    const progressParent = document.getElementById("progress");
    const progressBar = document.getElementById("progress-bar");

    ipcRenderer.on("checking-for-update", () => {
        state.innerHTML = `Checking for update...`;
    });

    ipcRenderer.on("new-update", (e, version) => {
        progressParent.style.display = "block";
        state.innerHTML = `New version found <b>${version}</b>!`;
    });

    ipcRenderer.on("download-progress", (e, progress) => {
        state.innerHTML = `Downloaded ${progress.transferred}Mb of ${progress.total}Mb`;
        progressBar.style.width = `${progress.percent}%`;
    });

    ipcRenderer.on("update-downloaded", () => {
        state.innerHTML = "Updated has been downloaded!";
        progressParent.style.display = "none";
    });

    ipcRenderer.on("error", (e, err) => {
        state.innerHTML = `Error: <b>${err}</b>!`;
    });
});
