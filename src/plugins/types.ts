export const EnabledDisabled = ["enabled", "disabled"] as const;
export type EnabledDisabledType = typeof EnabledDisabled[number];

export const UpdateChannels = ["latest", "beta", "alpha"] as const;
export type UpdateChannelsType = typeof UpdateChannels[number];

export const SideBarPosition = ["left", "right"] as const;
export type SideBarPositionType = typeof SideBarPosition[number];

export const TenToHundredPercent = [
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100,
] as const;
export type TenToHundredPercentType = typeof TenToHundredPercent[number];

export interface Settings {
    updateChannel: UpdateChannelsType;
    sideBarPosition: SideBarPositionType;
    discordRpc: EnabledDisabledType;
    discordRpcPrivacy: EnabledDisabledType;
    autoDetectTheme: EnabledDisabledType;
    darkMode: EnabledDisabledType;
    autoPlay: EnabledDisabledType;
    defaultPlayerWidth: TenToHundredPercentType;
    defaultPageWidth: TenToHundredPercentType;
}

export interface LastLeftEntity {
    title: string;
    episode?: {
        episode: string;
        watched: number;
        total: number;
    };
    reading?: {
        volume: string;
        chapter: string;
        read: string;
        total: string;
    };
    updatedAt: number;
    route: {
        route: string;
        queries: Record<string, string>;
    };
    showPopup: boolean;
}

export interface RecentlyBrowsedEntity {
    terms: string;
    searchedAt: number;
    resultsFound: number;
    route: {
        route: string;
        queries: Record<string, string | string[]>;
    };
}

export interface RecentlyViewedEntity {
    title: string;
    image: string;
    plugin: string;
    viewedAt: number;
    route: {
        route: string;
        queries: Record<string, string>;
    };
}

export interface BookmarkedEntity {
    title: string;
    image: string;
    plugin: string;
    bookmarkedAt: number;
    route: {
        route: string;
        queries: Record<string, string | string[]>;
    };
}
