import { DefineComponent } from "vue";
import { FontAwesomeIconProps } from "@fortawesome/vue-fontawesome";

declare module "vue" {
    export interface GlobalComponents {
        Icon: DefineComponent<FontAwesomeIconProps>;
    }
}

export {};
