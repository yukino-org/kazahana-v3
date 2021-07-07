<template>
    <div
        class="relative w-full h-auto flex justify-center items-center bg-black"
        @touchstart.passive="lastTouchedTime = Date.now()"
        @touchend="lastTouchedTime = 0"
        @mouseleave="handleOutOfFocus()"
        style="touch-action: none;"
    >
        <video
            class="w-full h-full pointer-events-none"
            :id="identifier"
            @loadedmetadata="initialize()"
            @canplay="isLoading = false"
            @waiting="isLoading = true"
            @ended="$emit('finish')"
            :style="{
                objectFit: videoMode,
                filter: `brightness(${brightness})`
            }"
        >
            <slot name="sources"></slot>
        </video>

        <button
            class="absolute focus:outline-none text-center text-4xl opacity-0 hover:opacity-100 transition duration-200 p-10"
            @click.stop.prevent="!!void (isPlaying ? pause() : play())"
            v-if="$state.props.runtime.isElectron"
        >
            <Icon icon="pause" v-if="isPlaying" />
            <Icon icon="play" v-else />
        </button>

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
                    class="focus:outline-none hover:opacity-80 transition duration-200"
                    @click.stop.prevent="
                        seekFromCurrent(skipIntroInterval);
                        isOptionOpened = false;
                    "
                >
                    <Icon class="mr-1" icon="fast-forward" /> Skip Intro
                </button>

                <button
                    class="focus:outline-none hover:opacity-80 transition duration-200"
                    @click.stop.prevent="togglePlayback()"
                >
                    <Icon class="mr-1" icon="forward" /> Speed
                    <span class="text-xs opacity-70"
                        >(x{{ playbackSpeed }})</span
                    >
                </button>

                <button
                    class="focus:outline-none hover:opacity-80 transition duration-200"
                    @click.stop.prevent="toggleMode()"
                >
                    <Icon class="mr-1" icon="video" /> Mode
                    <span class="text-xs opacity-70 capitalize"
                        >({{ videoMode }})</span
                    >
                </button>

                <button
                    class="focus:outline-none hover:opacity-80 transition duration-200"
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
                    @click.stop.prevent="handleVolumeSlider($event, 'click')"
                    @mousemove="handleVolumeSlider($event, 'mouse')"
                    @touchmove.capture="handleVolumeSlider($event, 'touch')"
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
                    <button
                        class="video-control"
                        @click.stop.prevent="
                            !!void seekFromCurrent(-defaultSeekLength)
                        "
                    >
                        <Icon icon="backward" />
                    </button>

                    <button
                        class="video-control text-sm"
                        @click.stop.prevent="
                            !!void (isPlaying ? pause() : play())
                        "
                    >
                        <Icon icon="pause" v-if="isPlaying" />
                        <Icon icon="play" v-else />
                    </button>

                    <button
                        class="video-control"
                        @click.stop.prevent="
                            !!void seekFromCurrent(defaultSeekLength)
                        "
                    >
                        <Icon icon="forward" />
                    </button>

                    <div
                        class="mx-2 flex-grow flex justify-center items-center relative h-3 cursor-pointer rounded"
                        @click.stop.prevent="
                            !!void handleProgressBar($event, 'click')
                        "
                        @mouseout="progressDot = null"
                        @mousemove="handleProgressDot($event, 'mouse')"
                        @mouseup="handleProgressBar($event, 'mouse')"
                        @touchmove.capture="
                            handleProgressDot($event, 'touch');
                            handleProgressBar($event, 'touch');
                        "
                    >
                        <div
                            class="absolute left-0 h-1 rounded bg-white pointer-events-none"
                            :style="{
                                width: `${duration.percent}%`
                            }"
                        ></div>

                        <div
                            class="absolute px-1 py-0.5 text-sm left-0 bottom-8 rounded bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white shadow pointer-events-none z-10 transition-opacity duration-200"
                            :style="{
                                left: progressDot
                                    ? `${progressDot}%`
                                    : undefined,
                                transform: 'translateX(-50%)',
                                visibility: progressDot ? 'visible' : 'hidden',
                                opacity: progressDot ? '1' : '0'
                            }"
                        >
                            {{
                                prettySecs(
                                    (progressDot ? progressDot / 100 : 0) *
                                        duration.totalSecs
                                )
                            }}
                        </div>

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

                    <button
                        class="video-control"
                        @click.stop.prevent="isVolumeOpened = !isVolumeOpened"
                    >
                        <Icon icon="volume-mute" v-if="volume === 0" />
                        <Icon icon="volume-down" v-else-if="volume < 0.5" />
                        <Icon icon="volume-up" v-else />
                    </button>

                    <button
                        class="video-control"
                        @click.stop.prevent="isOptionOpened = !isOptionOpened"
                    >
                        <Icon icon="cog" />
                    </button>

                    <button
                        class="video-control"
                        @click.stop.prevent="toggleFullscreen()"
                    >
                        <Icon icon="compress-alt" v-if="isFullscreened" />
                        <Icon icon="expand-alt" v-else />
                    </button>
                </div>
            </div>
        </transition>
    </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { Store, FullScreen } from "../plugins/api";
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
    emits: [
        "ready",
        "playing",
        "paused",
        "fullscreened",
        "fullscreenexit",
        "pipexit",
        "pipenter",
        "finish",
        "timechange"
    ],
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
            lastTouchedTime: number;
            gesturesEnabled: boolean;
            pressedKeys: string[];
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
            isLoading: true,
            lastTouchedTime: 0,
            gesturesEnabled: false,
            pressedKeys: []
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
            const store = await Store.getClient();
            const settings = await store.get(StoreKeys.settings);

            this.skipIntroInterval =
                settings?.skipIntroLength ||
                constants.defaults.settings.skipIntroLength;

            this.defaultSeekLength =
                settings?.defaultSeekLength ||
                constants.defaults.settings.defaultSeekLength;

            this.volume =
                (settings?.defaultVolume ||
                    constants.defaults.settings.defaultVolume) / 100;

            this.gesturesEnabled =
                (settings?.videoPlayerGestures ||
                    constants.defaults.settings.videoPlayerGestures) ===
                "enabled";
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

                player.parentElement?.addEventListener("mousemove", this.mouseMoveHandler);
                if (this.gesturesEnabled) {
                    player.parentElement?.addEventListener(
                        "touchmove",
                        this.touchMoveHandler,
                        {
                            capture: true,
                            passive: false
                        }
                    );
                }

                if (this.isPipSupported) {
                    player.parentElement?.addEventListener(
                        "enterpictureinpicture",
                        this.updatePip
                    );
                    player.parentElement?.addEventListener(
                        "leavepictureinpicture",
                        this.updatePip
                    );
                }

                document.addEventListener("keydown", this.handleKeyDown);
                document.addEventListener("keyup", this.handleKeyUp);
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

                player.parentElement?.removeEventListener("mousemove", this.mouseMoveHandler);
                if (this.gesturesEnabled) {
                    player.parentElement?.removeEventListener(
                        "touchmove",
                        this.touchMoveHandler
                    );
                }

                if (this.isPipSupported) {
                    player.parentElement?.removeEventListener(
                        "enterpictureinpicture",
                        this.updatePip
                    );
                    player.parentElement?.removeEventListener(
                        "leavepictureinpicture",
                        this.updatePip
                    );
                }

                document.removeEventListener("keydown", this.handleKeyDown);
                document.removeEventListener("keyup", this.handleKeyUp);
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
        async updateFullscreen() {
            this.isFullscreened = !!document.fullscreenElement;

            const fullscreen = await FullScreen.getClient();
            fullscreen?.set(this.isFullscreened);

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
        handleProgressBar(
            event: MouseEvent | TouchEvent,
            source: "click" | "mouse" | "touch"
        ) {
            const target = event.target as HTMLElement | null;
            if (!target) return;

            const player = this.getPlayer();
            if (!player) return;

            const { offsetX } =
                source === "touch"
                    ? util.getTouchOffset(event as TouchEvent)
                    : (event as MouseEvent);

            const time = (offsetX / target.offsetWidth) * player.duration;
            this.duration.playedSecs = time;
            player.currentTime = time;
        },
        prettySecs(duration: number) {
            const { days, hours, mins, secs } = util.parseMs(duration * 1000);
            return [
                ...[days, hours].filter(x => x),
                util.padNumber(mins, 2),
                util.padNumber(secs, 2)
            ].join(":");
        },
        async handleProgressDot(
            event: MouseEvent | TouchEvent,
            source: "mouse" | "touch"
        ) {
            const target = event.target as HTMLElement | null;
            if (!target) return;

            if (source === "mouse" && target.matches(":active")) {
                this.pause();
                this.handleProgressBar(event, "mouse");
            }

            const { offsetX } =
                source === "touch"
                    ? util.getTouchOffset(event as TouchEvent)
                    : (event as MouseEvent);

            this.progressDot = (offsetX / (target.offsetWidth || 0)) * 100;
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
            this.showSideVolume = false;
            this.showSideBrightness = false;
            this.isInFocus = false;
        },
        handleInFocus(
            event: MouseEvent | TouchEvent,
            source: "touch" | "mouse"
        ) {
            if (event.defaultPrevented) return;
            if (event.cancelable) event.preventDefault();

            this.isInFocus = true;

            const player = this.getPlayer();
            if (!player) return;

            const target = player.parentElement;
            if (!target) return;

            const active =
                source === "touch"
                    ? this.lastTouchedTime > 0 &&
                      Date.now() - this.lastTouchedTime > 300
                    : target.matches(":active");

            const { offsetX, offsetY } =
                source === "touch"
                    ? util.getTouchOffset(event as TouchEvent)
                    : (event as MouseEvent);

            const hadjust = 50;
            if (
                this.gesturesEnabled &&
                active &&
                offsetY > hadjust &&
                offsetY < target.offsetHeight
            ) {
                const wpcnt = (offsetX / target.offsetWidth) * 100,
                    hpcnt =
                        (1 -
                            (offsetY - hadjust) /
                                (target.offsetHeight - hadjust * 2)) *
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
            }

            let tmout: number | null = setTimeout(() => {
                this.handleOutOfFocus();
            }, 3000);

            target.addEventListener(
                source === "touch" ? "touchmove" : "mousemove",
                () => {
                    if (tmout !== null) {
                        clearTimeout(tmout);
                        tmout = null;
                    }
                },
                {
                    once: true,
                    passive: true
                }
            );
        },
        handleVolumeSlider(
            event: MouseEvent | TouchEvent,
            source: "click" | "mouse" | "touch"
        ) {
            console.log("called");

            const target = event.target as HTMLElement | null;
            if (!target) return;

            const player = this.getPlayer();
            if (!player) return;

            const active =
                source === "click" ||
                (source === "mouse" && target.matches(":active")) ||
                (source === "touch" &&
                    this.lastTouchedTime > 0 &&
                    Date.now() - this.lastTouchedTime > 300);

            if (active) {
                const { offsetY } =
                    source === "touch"
                        ? util.getTouchOffset(event as TouchEvent)
                        : (event as MouseEvent);

                const vol = 1 - offsetY / target.offsetHeight;
                if (util.isFiniteNumber(vol) && vol <= 1) {
                    this.volume = player.volume = vol;
                }
            }
        },
        seekFromCurrent(secs: number) {
            const player = this.getPlayer();
            if (!player) return;

            const seek = player.currentTime + secs,
                time =
                    seek < 0
                        ? 0
                        : seek > player.duration
                        ? player.duration
                        : seek;
            this.duration.playedSecs = time;
            player.currentTime = time;
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

            this.duration.playedSecs = duration;
            player.currentTime = duration;
        },
        mouseMoveHandler(event: MouseEvent) {
            this.handleInFocus(event, "mouse");
        },
        touchMoveHandler(event: TouchEvent) {
            this.handleInFocus(event, "touch");
        },
        handleKeyDown(event: KeyboardEvent) {
            this.pressedKeys.push(event.key);

            if (!event.defaultPrevented) {
                event.preventDefault();
                this.handleKeyboard();
            }
        },
        handleKeyUp(event: KeyboardEvent) {
            this.pressedKeys = this.pressedKeys.filter(x => x !== event.key);
        },
        handleKeyboard() {
            if (
                this.pressedKeys.length === 1 &&
                this.pressedKeys.includes(" ")
            ) {
                this.isPlaying ? this.pause() : this.play();
                return;
            }

            if (
                this.pressedKeys.length === 2 &&
                this.pressedKeys.includes("Shift") &&
                this.pressedKeys.includes("ArrowRight")
            ) {
                this.seekFromCurrent(this.defaultSeekLength);
                return;
            }

            if (
                this.pressedKeys.length === 2 &&
                this.pressedKeys.includes("Shift") &&
                this.pressedKeys.includes("ArrowLeft")
            ) {
                this.seekFromCurrent(-this.defaultSeekLength);
                return;
            }
        }
    }
});
</script>

<style scoped>
.video-control {
    @apply focus:outline-none hover:bg-white/20 px-2 py-1 rounded transition duration-200;
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
