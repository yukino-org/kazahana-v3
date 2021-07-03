<template>
    <div
        class="relative w-full h-auto flex justify-center items-center bg-black"
        @mouseleave="!!void handleOutOfFocus()"
        @mousemove="!!void handleInFocus($event)"
    >
        <video
            class="w-full h-full"
            :id="identifier"
            @loadedmetadata="initialize()"
            @canplay="isLoading = false"
            @waiting="isLoading = true"
            @click.stop.prevent="
                isInFocus ? handleOutOfFocus() : handleInFocus($event)
            "
            @ended="$emit('finish')"
            :style="{
                objectFit: videoMode,
                filter: `brightness(${brightness})`
            }"
        >
            <slot name="sources"></slot>
        </video>

        <transition name="fade">
            <div class="absolute top-4 right-4" v-if="isLoading">
                <svg
                    class="animate-spin h-5 w-5 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                >
                    <circle
                        class="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        stroke-width="4"
                    ></circle>
                    <path
                        class="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    ></path>
                </svg>
            </div>
        </transition>

        <transition name="fade">
            <div
                class="absolute text-white text-xs left-8 top-8 bottom-16 flex flex-col justify-center items-center gap-2"
                style="text-shadow: 0 0 0.25rem rgba(0, 0, 0, 40%);"
                v-if="showSideVolume"
            >
                <p class="text-[0.6rem]">Volume</p>
                <div class="flex-grow w-1.5 relative rounded overflow-hidden">
                    <div class="absolute w-full h-full bg-white/50"></div>
                    <div
                        class="absolute bottom-0 z-20 w-full bg-white rounded"
                        :style="{
                            height: `${volume * 100}%`
                        }"
                    ></div>
                </div>
                <p>{{ (volume * 100).toFixed(0) }}%</p>
            </div>
        </transition>

        <transition name="fade">
            <div
                class="absolute text-white text-xs right-8 top-8 bottom-16 flex flex-col justify-center items-center gap-2"
                style="text-shadow: 0 0 0.25rem rgba(0, 0, 0, 40%);"
                v-if="showSideBrightness"
            >
                <p class="text-[0.6rem]">Brightness</p>
                <div class="flex-grow w-1.5 relative rounded overflow-hidden">
                    <div class="absolute w-full h-full bg-white/50"></div>
                    <div
                        class="absolute bottom-0 z-20 w-full bg-white rounded"
                        :style="{
                            height: `${(brightness - 0.5) * 100}%`
                        }"
                    ></div>
                </div>
                <p>{{ (brightness * 100).toFixed(0) }}%</p>
            </div>
        </transition>

        <transition name="fade-pop">
            <div
                class="absolute z-10 bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-white bottom-11 right-5 px-3 py-1.5 rounded text-sm shadow grid gap-1"
                v-if="isOptionOpened"
            >
                <button
                    class="hover:opacity-80 transition duration-200"
                    @click.stop.prevent="
                        seekFromCurrent(85);
                        isOptionOpened = false;
                    "
                >
                    <Icon class="mr-1" icon="fast-forward" /> Skip Intro
                </button>

                <button
                    class="hover:opacity-80 transition duration-200"
                    @click.stop.prevent="togglePlayback()"
                >
                    <Icon class="mr-1" icon="forward" /> Speed
                    <span class="text-xs opacity-70"
                        >(x{{ playbackSpeed }})</span
                    >
                </button>

                <button
                    class="hover:opacity-80 transition duration-200"
                    @click.stop.prevent="toggleMode()"
                >
                    <Icon class="mr-1" icon="video" /> Mode
                    <span class="text-xs opacity-70 capitalize"
                        >({{ videoMode }})</span
                    >
                </button>

                <button
                    class="hover:opacity-80 transition duration-200"
                    @click.stop.prevent="
                        togglePIP();
                        isOptionOpened = false;
                    "
                    v-if="isPipSupported"
                >
                    <Icon class="mr-1" icon="external-link-alt" /> PIP
                </button>
            </div>
        </transition>

        <transition name="fade-pop">
            <div
                class="absolute z-10 bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-white bottom-11 right-[4.2rem] px-0.5 py-2 rounded text-sm shadow flex flex-col justify-center items-center"
                v-if="isVolumeOpened"
            >
                <div
                    class="w-4 h-20 relative mt-1 mb-2"
                    @click.stop.prevent="
                        !!void handleVolumeSlider($event, true)
                    "
                    @mousemove="handleVolumeSlider($event)"
                >
                    <div
                        class="absolute bg-gray-200 dark:bg-gray-700 bottom-0 w-2 h-full mx-1 pointer-events-none rounded"
                    ></div>
                    <div
                        class="absolute bg-indigo-500 bottom-0 w-2 mx-1 pointer-events-none rounded"
                        :style="{
                            height: `${volume * 100}%`
                        }"
                    ></div>
                </div>

                <p class="text-xs px-1.5">{{ (volume * 100).toFixed(0) }}%</p>
            </div>
        </transition>

        <transition name="fade">
            <div
                class="absolute left-0 right-0 bottom-0 bg-gradient-to-t from-gray-900/60 text-white w-[100% - 10px] text-sm px-2.5 pt-4 pb-2 select-none"
                v-if="!isPlaying || isInFocus || isPipEnabled"
            >
                <div class="flex flex-row justify-between items-center gap-0.5">
                    <div
                        class="video-control"
                        @click.stop.prevent="
                            !!void seekFromCurrent(-defaultSeekLength)
                        "
                    >
                        <Icon icon="backward" />
                    </div>

                    <div
                        class="video-control text-sm"
                        @click.stop.prevent="
                            !!void (isPlaying ? pause() : play())
                        "
                    >
                        <Icon icon="pause" v-if="isPlaying" />
                        <Icon icon="play" v-else />
                    </div>

                    <div
                        class="video-control"
                        @click.stop.prevent="
                            !!void seekFromCurrent(defaultSeekLength)
                        "
                    >
                        <Icon icon="forward" />
                    </div>

                    <div
                        class="mx-2 flex-grow flex justify-center items-center relative h-3 cursor-pointer"
                        @click.stop.prevent="!!void handleProgressBar($event)"
                        @mouseout="progressDot = null"
                        @mousemove="handleProgressDot($event)"
                        @mouseup="handleProgressBar($event)"
                    >
                        <div
                            class="absolute left-0 h-1 rounded bg-white pointer-events-none"
                            :style="{
                                width: `${duration.percent}%`
                            }"
                        ></div>

                        <div
                            class="absolute w-2.5 h-2.5 left-0 rounded-full bg-white shadow pointer-events-none z-10 transition-opacity duration-200"
                            :style="{
                                left: progressDot
                                    ? `calc(${progressDot}% - 3px)`
                                    : undefined,
                                visibility: progressDot ? 'visible' : 'hidden',
                                opacity: progressDot ? '1' : '0'
                            }"
                        ></div>

                        <div
                            class="absolute left-0 text-right-0 h-1 rounded w-full bg-white bg-opacity-50 pointer-events-none"
                        ></div>
                    </div>

                    <div class="text-xs mr-2">
                        <span>{{ prettySecs(duration.playedSecs) }}</span>
                        <span class="mx-1 opacity-60">/</span>
                        <span class="opacity-60">{{
                            prettySecs(duration.totalSecs)
                        }}</span>
                    </div>

                    <div
                        class="video-control"
                        @click.stop.prevent="
                            !!void (isVolumeOpened = !isVolumeOpened)
                        "
                    >
                        <Icon icon="volume-mute" v-if="volume === 0" />
                        <Icon icon="volume-down" v-else-if="volume < 0.5" />
                        <Icon icon="volume-up" v-else />
                    </div>

                    <div
                        class="video-control"
                        @click.stop.prevent="
                            !!void (isOptionOpened = !isOptionOpened)
                        "
                    >
                        <Icon icon="cog" />
                    </div>

                    <div
                        class="video-control"
                        @click.stop.prevent="!!void toggleFullscreen()"
                    >
                        <Icon icon="compress-alt" v-if="isFullscreened" />
                        <Icon icon="expand-alt" v-else />
                    </div>
                </div>
            </div>
        </transition>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store } from "../plugins/api/store/capacitor";
import { constants, util } from "../plugins/util";
import { StoreKeys } from "../plugins/types";

const fullscreenEvents: [string, string][] = [
    ["onfullscreenchange", "fullscreenchange"],
    ["onmozfullscreenchange", "mozfullscreenchange"],
    ["onwebkitfullscreenchange", "webkitfullscreenchange"]
];

const modes = ["contain", "cover", "fill"] as const;
type ModesType = typeof modes[number];

export default defineComponent({
    emits: {
        ready: () => true,
        playing: () => true,
        paused: () => true,
        fullscreened: () => true,
        fullscreenexit: () => true,
        pipexit: () => true,
        pipenter: () => true,
        finish: () => true,
        timechange: (current: number, total: number) => true
    },
    props: {
        autoplay: {
            type: Boolean,
            default: false
        }
    },
    data() {
        const data: {
            ready: boolean;
            identifier: string;
            isPlaying: boolean;
            isFullscreened: boolean;
            duration: {
                playedSecs: number;
                totalSecs: number;
                percent: number;
            };
            progressDot: number | null;
            isOptionOpened: boolean;
            playbackSpeed: number;
            volume: number;
            isVolumeOpened: boolean;
            isPipSupported: boolean;
            isPipEnabled: boolean;
            videoMode: ModesType;
            isInFocus: boolean;
            skipIntroInterval: number;
            brightness: number;
            showSideVolume: boolean;
            showSideBrightness: boolean;
            defaultSeekLength: number;
            isLoading: boolean;
        } = {
            ready: false,
            identifier: `player-${util.randomText(10)}`,
            isPlaying: false,
            isFullscreened: false,
            duration: {
                playedSecs: 0,
                totalSecs: 0,
                percent: 0
            },
            progressDot: null,
            isOptionOpened: false,
            playbackSpeed: 1,
            volume: 1,
            isVolumeOpened: false,
            // @ts-ignore
            isPipSupported: document.pictureInPictureEnabled,
            isPipEnabled: false,
            videoMode: "contain",
            isInFocus: false,
            skipIntroInterval: 0,
            brightness: 1,
            showSideVolume: false,
            showSideBrightness: false,
            defaultSeekLength: 0,
            isLoading: true
        };

        return data;
    },
    mounted() {
        this.handleMount();
    },
    beforeDestroy() {
        this.detachHandlers();
    },
    methods: {
        async handleMount() {
            const settings = await Store.get(StoreKeys.settings);

            this.skipIntroInterval =
                settings?.skipIntroLength ||
                constants.defaults.settings.skipIntroLength;

            this.defaultSeekLength =
                settings?.defaultSeekLength ||
                constants.defaults.settings.defaultSeekLength;

            this.volume =
                (settings?.defaultVolume ||
                    constants.defaults.settings.defaultVolume) / 100;
        },
        initialize() {
            const player = this.getPlayer();
            if (!player) return;

            this.updatePlayPause();
            this.updateDuration();
            this.attachHandlers();

            player.playbackRate = this.playbackSpeed;
            player.volume = this.volume;

            if (this.autoplay) player.play();

            this.isLoading = false;
            this.ready = true;
            this.$emit("ready");
        },
        attachHandlers() {
            fullscreenEvents.forEach(([ev, name]) => {
                if (ev in document) {
                    document.addEventListener(name, this.updateFullscreen);
                }
            });

            const player = this.getPlayer();
            if (player) {
                player.addEventListener("play", this.updatePlayPause);
                player.addEventListener("pause", this.updatePlayPause);

                player.addEventListener("timeupdate", this.updateDuration);
                player.addEventListener("durationchange", this.updateDuration);

                if (this.isPipSupported) {
                    player.addEventListener(
                        "enterpictureinpicture",
                        this.updatePip
                    );
                    player.addEventListener(
                        "leavepictureinpicture",
                        this.updatePip
                    );
                }

                document.addEventListener("keypress", this.handleKeypress);
            }
        },
        detachHandlers() {
            fullscreenEvents.forEach(([ev, name]) => {
                if (ev in document) {
                    document.removeEventListener(name, this.updateFullscreen);
                }
            });

            const player = this.getPlayer();
            if (player) {
                player.removeEventListener("play", this.updatePlayPause);
                player.removeEventListener("pause", this.updatePlayPause);

                player.removeEventListener("timeupdate", this.updateDuration);
                player.removeEventListener(
                    "durationchange",
                    this.updateDuration
                );

                if (this.isPipSupported) {
                    player.removeEventListener(
                        "enterpictureinpicture",
                        this.updatePip
                    );
                    player.removeEventListener(
                        "leavepictureinpicture",
                        this.updatePip
                    );
                }

                document.removeEventListener("keypress", this.handleKeypress);
            }
        },
        play() {
            const player = this.getPlayer();
            if (!player) return;

            return player.play();
        },
        pause() {
            const player = this.getPlayer();
            if (!player) return;

            player.pause();
        },
        updatePlayPause() {
            const player = this.getPlayer();
            if (!player) return;

            this.isPlaying = !player.paused;
            if (this.isPlaying) this.$emit("playing");
            else this.$emit("paused");
        },
        updateDuration() {
            const player = this.getPlayer();
            if (!player) return;

            this.duration.playedSecs = player.currentTime;
            this.duration.totalSecs = player.duration;
            this.duration.percent =
                (this.duration.playedSecs / this.duration.totalSecs) * 100 || 0;

            this.$emit(
                "timechange",
                this.duration.playedSecs,
                this.duration.totalSecs
            );
        },
        updateFullscreen() {
            this.isFullscreened = !!document.fullscreenElement;

            if (this.isFullscreened) this.$emit("fullscreened");
            else this.$emit("fullscreenexit");
        },
        async toggleFullscreen() {
            const player = this.getPlayer();
            if (!player) return;

            if (this.isFullscreened) {
                await document.exitFullscreen();
            } else {
                await player.parentElement?.requestFullscreen();
            }
        },
        getPlayer() {
            return document.getElementById(
                this.identifier
            ) as HTMLVideoElement | null;
        },
        handleProgressBar(event: MouseEvent) {
            const target = event.target as HTMLElement | null;
            if (!target) return;

            const player = this.getPlayer();
            if (!player) return;

            this.duration.playedSecs = player.currentTime =
                (event.offsetX / target.offsetWidth) * player.duration;
        },
        handleKeypress(event: KeyboardEvent) {
            if (event.key === " ") {
                this.isPlaying ? this.pause() : this.play();
            }
        },
        prettySecs(duration: number) {
            const { days, hours, mins, secs } = util.parseMs(duration * 1000);
            return [
                ...[days, hours].filter(x => x),
                util.padNumber(mins, 2),
                util.padNumber(secs, 2)
            ].join(":");
        },
        async handleProgressDot(event: MouseEvent) {
            const target = event.target as HTMLElement | null;
            if (!target) return;

            if (target.matches(":active")) {
                this.pause();
                this.handleProgressBar(event);
            }

            this.progressDot =
                (event.offsetX / (target.offsetWidth || 0)) * 100;
        },
        togglePlayback() {
            const player = this.getPlayer();
            if (!player) return;

            const speeds = [0.25, 0.5, 0.75, 1, 2, 3, 4],
                n = speeds.indexOf(player.playbackRate);

            this.playbackSpeed = player.playbackRate =
                speeds[n + 1] || speeds[0];
        },
        toggleMode() {
            const player = this.getPlayer();
            if (!player) return;

            const n = modes.indexOf(this.videoMode);

            this.videoMode = modes[n + 1] || modes[0];
        },
        handleOutOfFocus() {
            this.isOptionOpened = false;
            this.isVolumeOpened = false;
            this.showSideVolume = false;
            this.showSideBrightness = false;
            this.isInFocus = false;
        },
        handleInFocus($event: MouseEvent) {
            this.isInFocus = true;

            const player = this.getPlayer();
            if (!player) return;

            if (player.parentElement) {
                const clicked = player.parentElement.matches(":active");

                const hadjust = 50;
                if (
                    clicked &&
                    $event.offsetY > hadjust &&
                    $event.offsetY < player.offsetHeight
                ) {
                    const wpcnt =
                            ($event.offsetX /
                                player.parentElement.offsetWidth) *
                            100,
                        hpcnt =
                            (1 -
                                ($event.offsetY - hadjust) /
                                    (player.parentElement.offsetHeight -
                                        hadjust * 2)) *
                            1.1;

                    if (util.isFiniteNumber(hpcnt) && hpcnt <= 1) {
                        if (wpcnt < 40) {
                            this.showSideBrightness = true;
                            this.brightness = hpcnt + 0.5;
                        } else if (wpcnt > 60) {
                            this.showSideVolume = true;
                            this.volume = player.volume = hpcnt;
                        }
                    }
                } else {
                    const tmout = setTimeout(() => {
                        this.isInFocus = false;
                    }, 3000);

                    player.parentElement.addEventListener(
                        "mousemove",
                        () => {
                            clearTimeout(tmout);
                        },
                        {
                            once: true
                        }
                    );
                }
            }
        },
        handleVolumeSlider(event: MouseEvent, ignoreActive = false) {
            const target = event.target as HTMLElement | null;
            if (!target) return;

            const player = this.getPlayer();
            if (!player) return;

            if (ignoreActive || target.matches(":active")) {
                const vol = 1 - event.offsetY / target.offsetHeight;
                if (util.isFiniteNumber(vol) && vol <= 1) {
                    this.volume = player.volume = vol;
                }
            }
        },
        seekFromCurrent(secs: number) {
            const player = this.getPlayer();
            if (!player) return;

            const seek = player.currentTime + secs;
            this.duration.playedSecs = player.currentTime =
                seek < 0 ? 0 : seek > player.duration ? player.duration : seek;
        },
        async togglePIP() {
            const player = this.getPlayer();
            if (!player) return;

            if (this.isPipEnabled) {
                // @ts-ignore
                await document.exitPictureInPicture();
            } else {
                // @ts-ignore
                await player.requestPictureInPicture();
            }
        },
        updatePip() {
            // @ts-ignore
            this.isPipEnabled = !!document.pictureInPictureElement;

            if (this.isPipEnabled) this.$emit("pipenter");
            else this.$emit("pipexit");
        },
        seekTo(duration: number) {
            const player = this.getPlayer();
            if (!player) return;

            this.duration.playedSecs = player.currentTime = duration;
        }
    }
});
</script>

<style scoped>
.video-control {
    @apply hover:bg-white/20 px-1.5 py-0.5 rounded cursor-pointer transition duration-200;
}

.fade-pop-enter-from,
.fade-pop-leave-to {
    opacity: 0;
    transform: translateY(0.5rem) scale(0.9);
}

.fade-pop-enter-active,
.fade-pop-leave-active {
    transition: 0.3s;
}
</style>
