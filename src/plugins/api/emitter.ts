export type Subscriber<P> = (param: P) => void;

export type UnknownFn = (...args: any[]) => void;
export interface EmitterSkeleton {
    [s: string]: UnknownFn;
}

export class Emitter<Skeleton extends EmitterSkeleton> {
    _subscribers: {
        [e in keyof Skeleton]?: Skeleton[e][];
    } = {};

    constructor() {}

    subscribe<T extends keyof Skeleton>(event: T, handler: Skeleton[T]) {
        if (!this._subscribers[event]) this._subscribers[event] = [];
        this._subscribers[event]!.push(handler);
        return this.unsubscribe.bind(this, event, handler);
    }

    unsubscribe<T extends keyof Skeleton>(event: T, handler: Skeleton[T]) {
        if (!this._subscribers[event]) return;
        this._subscribers[event] = this._subscribers[event]!.filter(
            x => x !== handler
        );
    }

    dispatch<T extends keyof Skeleton>(
        event: T,
        ...params: Parameters<Skeleton[T]>
    ) {
        this._subscribers[event]?.forEach(sub => {
            sub(...params);
        });
    }
}
