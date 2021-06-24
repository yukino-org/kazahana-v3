import { util, RecursivePartial } from "../util";

export type StateUpdateState<T> = {
    previous: T;
    current: T;
};

export type StateUpdateDispatcher<T> = (state: StateUpdateState<T>) => void;

export class State<T> {
    dispatcher?: StateUpdateDispatcher<T>;
    _props: T;

    constructor(props: T) {
        this._props = props;
    }

    setDispatcher(dispatcher: StateUpdateDispatcher<T>) {
        this.dispatcher = dispatcher;
    }

    update(value: RecursivePartial<T>) {
        const previous = { ...this._props };
        const current = util.mergeObject(this._props, value);
        this._props = current;
        this.dispatcher?.({
            previous,
            current
        });
    }

    get props() {
        return { ...this._props };
    }
}
