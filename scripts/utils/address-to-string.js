/**
 * @param {import("net").AddressInfo | string} address
 * @param {boolean} [https]
 */
module.exports = (address, https = false) => {
    return typeof address === "string"
        ? address
        : `${https ? "https" : "http"}://${address.address}:${address.port}`;
};
