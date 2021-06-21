export type Subscriber<P> = (param: P) => void;

export class Emitter<P = any> {
    _subscribers: Subscriber<P>[] = [];

    constructor() {}

    subscribe(handler: Subscriber<P>) {
        this._subscribers.push(handler);
        return this.unsubscribe.bind(this, handler);
    }

    unsubscribe(handler: Subscriber<P>) {
        this._subscribers = this._subscribers.filter((x) => x !== handler);
    }

    dispatch(param: P) {
        this._subscribers.forEach((sub) => {
            sub(param);
        });
    }
}
