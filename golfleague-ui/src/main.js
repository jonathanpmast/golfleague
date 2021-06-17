import { createApp } from 'vue'
import App from './App.vue'
import './index.css'
import router from "./router"
import { MSALPlugin } from './plugins/msal-plugin';


const options = {
    clientId: import.meta.env.VITE_VUE_APP_MSAL_CLIENT_ID,
    loginAuthority:  import.meta.env.VITE_VUE_APP_MSAL_LOGIN_AUTHORITY,
    passwordAuthority: import.meta.env.VITE_VUE_APP_MSAL_PASSWORD_RESET_AUTHORITY,
    knownAuthority: import.meta.env.VITE_VUE_APP_MSAL_KNOWN_AUTHORITY,
    redirectUri: import.meta.env.VITE_VUE_APP_MSAL_REDIRECT_URL
  };

createApp(App).use(new MSALPlugin(),options).use(router).mount('#app')
