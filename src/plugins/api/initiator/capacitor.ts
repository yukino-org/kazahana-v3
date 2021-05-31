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
        const res: any[] = JSON.parse(
            await client.get(
                "https://api.github.com/repos/zyrouge/yukino-app/releases",
                {
                    headers: {},
                }
            )
        );

        const latest = res
            .filter((x) => !x.draft)
            .sort(
                (a, b) =>
                    new Date(a.updated_at).getTime() -
                    new Date(b.updated_at).getTime()
            )[0];

        if (latest && app_version !== latest) {
            const { value } = await Dialog.confirm({
                title: "Update",
                message: `Newer version of the app is available! (${app_version} -> ${latest.tag_name})\nWould you like to download it?`,
            });

            if (value) {
                const opener = await ExternalLink.getClient();
                opener?.(latest.html_url);
            }
        }
    } catch (err) {}
}
