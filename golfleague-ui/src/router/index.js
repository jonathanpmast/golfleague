import { createWebHistory, createRouter } from "vue-router";
import Home from "../views/Home.vue";
import About from "../views/About.vue";
import Skins from "../views/Skins.vue";

const routes = [
    {
        path: "/",
        name: "Home",
        component: Home
    },
    {
        path: "/about",
        name: "About",
        component: About
    },
    {
        path: "/Skins",
        name: "Skins",
        component: Skins
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;