import * as msal from "@azure/msal-browser";
import {reactive, ref} from "vue";

let msalInstance = msal.PublicClientApplication;
let userInfo = ref(null);
export let msalPluginInstance = null;

export class MSALPlugin{ 
    pluginOptions = {
        clientId: "",
        loginAuthority: "",
        passwordAuthority: "",
        knownAuthority: ""
    };

    install = (app, options) => {
        if (!options) {
            throw new Error("MsalPluginOptions must be specified");
        }
        console.log(options);
        this.pluginOptions = options;
        this.initialize(options);
        msalPluginInstance = this;

        let reactiveMsalPluginInstance = reactive(msalPluginInstance);
        
        app.provide('msalPluginInstance', reactiveMsalPluginInstance);
        app.provide('userInfo',userInfo);
        this.ensureUserInfo();
    };

    initialize = (options) => {
        const msalConfig= {
            auth: {
                clientId: options.clientId,
                authority: options.loginAuthority,
                knownAuthorities: [options.knownAuthority]
            },
            system: {
                loggerOptions: {
                    loggerCallback: (level, message, containsPii)=> {
                        if (containsPii) {
                            return;
                        }
                        switch (level) {
                            case msal.LogLevel.Error:
                                console.error(message);
                                return;
                            case msal.LogLevel.Info:
                                console.info(message);
                                return;
                            case msal.LogLevel.Verbose:
                                console.debug(message);
                                return;
                            case msal.LogLevel.Warning:
                                console.warn(message);
                                return;
                        }
                    },
                    piiLoggingEnabled: false,
                    logLevel: msal.LogLevel.Verbose
                }
            }
        };
        msalInstance = new msal.PublicClientApplication(msalConfig);
        
    }

    signIn = async () => {
        try {
            const loginRequest = {
                scopes: ["openid", "profile", "offline_access"],
            };
            const loginResponse = await msalInstance.loginPopup(loginRequest);     
            userInfo.value = loginResponse.account       
        } catch (err) {
            // handle error
            if (err.errorMessage && err.errorMessage.indexOf("AADB2C90118") > -1) {
                try {
                    const passwordResetResponse= await msalInstance.loginPopup({
                        scopes: ["openid", "profile", "offline_access", "test"],
                        authority: this.pluginOptions.passwordAuthority
                    });
                    userInfo.value = passwordResetResponse.account;
                } catch (passwordResetError) {
                    console.error(passwordResetError);
                }
            } else {
                userInfo.value = null;
            }

        }
    }

    signOut = async () => {
        await msalInstance.logout();
        userInfo.value = null;
    }

    acquireToken = async () => {
        const request = {
            account: msalInstance.getAllAccounts()[0],
            scopes: ["test"]
        };
        try {
            const response = await msalInstance.acquireTokenSilent(request);
            this.ensureUserInfo();
            return response.accessToken;            
        } catch (error) {
            if (error instanceof msal.InteractionRequiredAuthError) {
                return msalInstance.acquireTokenPopup(request).catch((popupError) => {
                    console.error(popupError);
                });
            }
            return false;
        }
    }

    getIsAuthenticated = () =>{
        
        const accounts = msalInstance.getAllAccounts();
        if(accounts && accounts.length > 0) {
            return true;
        }
    }

    ensureUserInfo = () => {
        if(!userInfo.value && this.getIsAuthenticated()) {
            userInfo.value = msalInstance.getAllAccounts()[0];
        }
    }
}