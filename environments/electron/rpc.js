const {
    productName,
    description,
    version,
    homepage,
} = require("../../package.json");
const { Client: DiscordRPC } = require("discord-rpc");
const Logger = require("./logger");
const Store = require("./store");
const Util = require("./util");

/**
 * @typedef Activity
 * @property {number} startTimestamp
 * @property {string} details
 * @property {string} state
 * @property {{ label: string; url: string; }[]} buttons
 */

class RPC {
    constructor() {
        /**
         * @type {string}
         */
        this.id = "845615853479133194";

        /**
         * @type {DiscordRPC["prototype"]}
         */
        this.rpc = new DiscordRPC({
            transport: "ipc",
        });

        /**
         * @type {number}
         */
        this.started = Date.now();

        /**
         * @type {boolean}
         */
        this.disabled = Store.store.get("settings.discordRpc") === "disabled";

        /**
         * @type {boolean}
         */
        this.privacyMode =
            Store.store.get("settings.discordRpcPrivacy") === "enabled";

        /**
         * @type {boolean}
         */
        this.ready = false;

        /**
         * @type {boolean}
         */
        this.alreadySetInPrivacyMode = false;
    }

    /**
     * @param {Partial<Activity>} activity
     * @returns {void}
     */
    setActivity(activity) {
        try {
            if (this.ready) {
                if (this.privacyMode) {
                    if (!this.alreadySetInPrivacyMode) {
                        this.rpc.setActivity(this.defaultActivity);
                        this.alreadySetInPrivacyMode = true;
                    }
                    return;
                }

                this.rpc.setActivity(
                    Util.mergeObj(this.defaultActivity, activity)
                );

                if (activity.startTimestamp)
                    this.started = activity.startTimestamp;
            }
        } catch (err) {
            Logger.error("discord-rpc", `Failed to set Rpc activity: ${err}`);
        }
    }

    /**
     * @returns {Promise<boolean>}
     */
    connect() {
        if (this.disabled) {
            Logger.debug("discord-rpc", "Rpc is disabled");
            return false;
        }

        return new Promise((resolve) => {
            this.rpc.on("ready", () => {
                this.ready = true;
                if (this.rpc.user) {
                    Logger.debug(
                        "discord-rpc",
                        `RPC set for ${this.rpc.user.username}#${this.rpc.user.discriminator} (${this.rpc.user.id})`
                    );
                }

                resolve(true);
            });

            this.rpc
                .login({
                    clientId: this.id,
                })
                .catch((err) => {
                    Logger.error(
                        "discord-rpc",
                        `Failed to connect to Rpc: ${err}`
                    );
                    resolve(false);
                });
        });
    }

    /**
     * @type {Activity}
     */
    get defaultActivity() {
        return {
            startTimestamp: this.started,
            largeImageKey: "large",
            largeImageText: `${productName} v${version}`,
            smallImageKey: "snowflake_inverted",
            smallImageText: description,
            buttons: [
                {
                    label: "Download App",
                    url: homepage,
                },
            ],
        };
    }
}

module.exports = new RPC();
