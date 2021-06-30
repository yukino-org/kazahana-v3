import { DefineComponent } from "vue";
import { RouteComponent, RouterView } from "vue-router";
import { FontAwesomeIconProps } from "@fortawesome/vue-fontawesome";

declare module "vue" {
    export interface GlobalComponents {
        Icon: DefineComponent<FontAwesomeIconProps>;
        "router-link": RouteComponent;
        "router-view": typeof RouterView;
    }
}

export {};
