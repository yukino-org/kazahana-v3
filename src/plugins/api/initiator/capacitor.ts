import { SplashScreen } from "@capacitor/splash-screen";
import { InitiatorFn } from "./";

export const initiator: InitiatorFn = async () => {
    await SplashScreen.hide();
};
