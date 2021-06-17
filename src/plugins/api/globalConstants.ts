import { constants, util, RecursivePartial } from "../util";
import { Store } from "./store";

export interface GlobalConstantsProps {
    autoDetectTheme: boolean;
    isDarkTheme: boolean;
}

export type GlobalConstantsPropsChangeHandler = (
    previous: GlobalConstantsProps,
    current: GlobalConstantsProps
) => any;

export class GlobalConstants {
    handlers: GlobalConstantsPropsChangeHandler[] = [];
    props: GlobalConstantsProps = {
        autoDetectTheme: false,
        isDarkTheme: false,
    };

    constructor() {}

    async get() {
        const store = await Store.getClient();
        const settings: Record<string, any> | undefined = await store.get(
            constants.storeKeys.settings
        );

        this.props.autoDetectTheme =
            (settings?.autoDetectTheme ||
                constants.defaults.settings.autoDetectTheme) === "enabled";

        this.props.isDarkTheme =
            (settings?.darkMode || constants.defaults.settings.darkMode) ===
            "enabled";

        return this;
    }

    update(value: RecursivePartial<GlobalConstantsProps>) {
        const oldValue = { ...this.props };
        const newValue = util.mergeObject(this.props, value);
        this.props = newValue;

        this.handlers.forEach((fn) => {
            fn(oldValue, newValue);
        });
    }

    listen(handler: GlobalConstantsPropsChangeHandler) {
        this.handlers.push(handler);
    }
}

export default new GlobalConstants();
