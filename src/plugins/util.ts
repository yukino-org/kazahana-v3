export default {
    getHighResMALImage(url: string) {
        return url.replace(
            /(https:\/\/cdn.myanimelist\.net\/).*(images.*)\?.*/g,
            "$1$2"
        );
    },
};
