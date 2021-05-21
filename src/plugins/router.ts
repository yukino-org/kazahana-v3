import { createRouter, createWebHashHistory, RouteRecordRaw } from "vue-router";

const routes: RouteRecordRaw[] = [
    { path: "/", component: () => import("../pages/Home.vue") },
    { path: "/search", component: () => import("../pages/Search.vue") },
    {
        path: "/anime",
        component: () => import("../pages/Anime.vue"),
    },
    {
        path: "/anime/source",
        component: () => import("../pages/AnimeSourceInfo.vue"),
    },
    {
        path: "/manga/source",
        component: () => import("../pages/MangaSourceInfo.vue"),
    },
    {
        path: "/settings",
        component: () => import("../pages/Settings.vue"),
    },
];

const router = createRouter({
    history: createWebHashHistory(),
    routes,
});

export default router;
