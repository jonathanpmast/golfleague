import * as msal from "@azure/msal-browser";
import {reactive} from "vue";

let msalInstance = msal.PublicClientApplication;

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
        this.pluginOptions = options;
        this.initialize(options);
        msalPluginInstance = this;
        app.config.globalProperties.$msal = reactive(msalPluginInstance);
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
        this.isAuthenticated = this.getIsAuthenticated();
    }

    signIn = async () => {
        try {
            const loginRequest = {
                scopes: ["openid", "profile", "offline_access", "https://davecob2cc.onmicrosoft.com/bcc7d959-3458-4197-a109-26e64938a435/access_api"],
            };
            const loginResponse = await msalInstance.loginPopup(loginRequest);
            this.isAuthenticated = !!loginResponse.account;
            // do something with this?
        } catch (err) {
            // handle error
            if (err.errorMessage && err.errorMessage.indexOf("AADB2C90118") > -1) {
                try {
                    const passwordResetResponse= await msalInstance.loginPopup({
                        scopes: ["openid", "profile", "offline_access", "<The scope for your API>"],
                        authority: this.pluginOptions.passwordAuthority
                    });
                        this.isAuthenticated = !!passwordResetResponse.account;
                } catch (passwordResetError) {
                    console.error(passwordResetError);
                }
            } else {
                this.isAuthenticated = false;
            }

        }
    }

    signOut = async () => {
        await msalInstance.logout();
        this.isAuthenticated = false;
    }

    acquireToken = async () => {
        const request = {
            account: msalInstance.getAllAccounts()[0],
            scopes: ["<The scope for your API>"]
        };
        try {
            const response = await msalInstance.acquireTokenSilent(request);
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
        return accounts && accounts.length > 0;
    }
}