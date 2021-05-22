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

class RPC {
    constructor() {
        this.id = "845615853479133194";
        this.rpc = new DiscordRPC({
            transport: "ipc",
        });
        this.started = Date.now();
        this.disabled = Store.store.get("settings.discordRpc") === "disabled";
        this.ready = false;
    }

    /**
     * @typedef Activity
     * @property {number} startTimestamp
     * @property {string} details
     * @property {string} state
     * @property {{ label: string; url: string; }[]} buttons
     */

    /**
     * @param {Partial<Activity>} activity
     */
    setActivity(activity) {
        try {
            if (this.ready) {
                this.rpc.setActivity(
                    Util.mergeObj(
                        {
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
                        },
                        activity
                    )
                );

                if (activity.startTimestamp)
                    this.started = activity.startTimestamp;
            }
        } catch (err) {
            Logger.error(`Failed to set Rpc activity: ${err}`);
        }
    }

    /**
     * @returns {Promise<boolean}
     */
    connect() {
        if (this.disabled) {
            Logger.info("Rpc is disabled");
            return false;
        }

        return new Promise((resolve) => {
            this.rpc.on("ready", () => {
                this.ready = true;
                if (this.rpc.user) {
                    Logger.info(
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
                    Logger.error(`Failed to connect to Rpc: ${err}`);
                    resolve(false);
                });
        });
    }
}

module.exports = new RPC();
