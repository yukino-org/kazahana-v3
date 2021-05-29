import { App } from "@capacitor/app";
import { SplashScreen } from "@capacitor/splash-screen";
import { InitiatorFn } from "./";
import Router from "../../router";

export const initiator: InitiatorFn = async () => {
    await SplashScreen.hide();

    App.addListener("backButton", () => {
        try {
            Router.go(-1);
        } catch (err) {}
    });
};
