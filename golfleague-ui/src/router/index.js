import { createWebHistory, createRouter } from "vue-router";
import Home from "../views/Home.vue";
import About from "../views/About.vue";
import Skins from "../views/Skins.vue";
import Login from "../views/Login.vue";
import ScoreEntry from "../views/ScoreEntry.vue";
import Config from "../views/Config.vue";

const routes = [
    {
        path: "/",
        redirect: "/bmgnky" // Default redirect to default league
    },
    {
        path: "/:leagueName",
        name: "Home",
        component: Home
    },
    {
        path: "/:leagueName/about",
        name: "About",
        component: About
    },
    {
        path: "/:leagueName/scores",
        name: "ScoreEntry",
        component: ScoreEntry
    },
    {
        path: "/:leagueName/skins/:year?/:round?",
        name: "Skins",
        component: Skins
    },
    {
        path: "/:leagueName/login",
        name: "Login",
        component: Login
    },
    {
        path: "/:leagueName/config",
        name: "Config",
        component: Config
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;