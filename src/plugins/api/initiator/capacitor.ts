import { App } from "@capacitor/app";
import { SplashScreen } from "@capacitor/splash-screen";
import { Dialog } from "@capacitor/dialog";
import { InitiatorFn } from "./";
import Router from "../../router";
import { http } from "../requester";
import { ExternalLink } from "../externalLink";

export const initiator: InitiatorFn = async () => {
    await SplashScreen.hide();

    App.addListener("backButton", () => {
        try {
            Router.go(-1);
        } catch (err) {}
    });

    notifyUpdate();
};

async function notifyUpdate() {
    try {
        const client = await http.getClient();
        const release: any = (<any[]>JSON.parse(
            await client.get(
                "https://api.github.com/repos/zyrouge/yukino-app/releases",
                {
                    headers: {},
                }
            )
        ))
            .sort(
                (a, b) =>
                    new Date(b.published_at).getTime() -
                    new Date(a.published_at).getTime()
            )
            .find(
                (x) =>
                    !x.draft &&
                    x.assets.some((y: any) => y.name.endsWith(".apk")) &&
                    x.assets.some((y: any) => y.name === "latest-android.json")
            );

        if (release) {
            const manifest = release.assets.find(
                (x: any) => x.name === "latest-android.json"
            )?.browser_download_url;

            if (manifest) {
                const { version: latestVersion } = JSON.parse(
                    await client.get(manifest, {
                        headers: {},
                    })
                );

                if (latestVersion && app_version !== latestVersion) {
                    const { value } = await Dialog.confirm({
                        title: "Update",
                        message: `Newer version of the app is available! (v${app_version} -> v${latestVersion})\nWould you like to download it?`,
                    });

                    if (value) {
                        const opener = await ExternalLink.getClient();
                        opener?.(release.html_url);
                    }
                }
            }
        }
    } catch (err) {
        console.error(`Update failed: ${err?.message}`);
    }
}
